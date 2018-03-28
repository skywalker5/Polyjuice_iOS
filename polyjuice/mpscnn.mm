//
//  mpscnn.cpp
//  polyjuice
//
//  Created by DJ on 2018. 3. 7..
//  Copyright © 2018년 DJ. All rights reserved.
//

#include "mpscnn.h"
#include "mpscnn_context.h"
//#include "mpscnn_kernels.h"
#include "timer.h"
#include <vector>

#import <Metal/Metal.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>
#import <UIKit/UIDevice.h>

using namespace std;

struct Blob {
    MPSImage* image_;
    id<MTLCommandBuffer> commandBuffer_;
    bool isTemporaryImage_;
};

auto divRoundUp(uint x, uint y) -> uint {
    return (x + y - 1) / y;
}

MPSTemporaryImage* createTemporaryImage(id<MTLCommandBuffer> commandBuffer,
                                        int n,
                                        int height,
                                        int width,
                                        int channels,
                                        size_t output_idx = 0) {
    auto* image = [MPSTemporaryImage
                   temporaryImageWithCommandBuffer:commandBuffer
                   imageDescriptor:
                   [MPSImageDescriptor
                    imageDescriptorWithChannelFormat:
                    MPSImageFeatureChannelFormatFloat16
                    width:width
                    height:height
                    featureChannels:channels
                    numberOfImages:n
                    usage:
                    MTLTextureUsageShaderRead |
                    MTLTextureUsageShaderWrite]];
    
//    // We'll try to look at the per-output_idx read-count argument, otherwise,
//    // we'll use the operator-global default.
//    const auto& readCounts = op->GetRepeatedArgument<int>(kMPSCNNReadCountArg);
//    const auto readCount = readCounts.size()
//    ? readCounts.at(output_idx)
//    : op->GetSingleArgument<int>(kMPSCNNReadCountArg, 1);
//    CAFFE_ENFORCE_GE(readCount, 1);
//    image.readCount = readCount;
    return image;
}

MPSImage* createStaticImage(int n, int height, int width, int channels) {
    return [[MPSImage alloc]
            initWithDevice:getMPSCNNContext().device
            imageDescriptor:
            [MPSImageDescriptor
             imageDescriptorWithChannelFormat:
             MPSImageFeatureChannelFormatFloat16
             width:width
             height:height
             featureChannels:channels
             numberOfImages:n
             usage:MTLTextureUsageShaderRead |
             MTLTextureUsageShaderWrite]];
}

class MPSImageWrapper {
public:
    MPSImageWrapper() {}
    MPSImageWrapper(MPSImageWrapper* parent,
                    int n,
                    int height,
                    int width,
                    int channels,
                    size_t output_idx = 0) {
        /* If the parent wrapper contains a temporary image, we need to pass on the
         * command buffer because the temporary images are attached to the command
         * buffer, we will need to use the same command buffer in order to use the
         * temporary image. We don't want to synchronize the parent wrapper because
         * it is still in use. If the parent wrapper contains a static image, we
         * should create a new command buffer because we use static image so it can
         * survive synchronization(commit of the command buffer), which means if we
         * pass on the command buffer the command buffer will be commited in
         * multiple places in the graph. Also since we don't pass on parent's
         * command buffer,we need to synchronize(commit) it since it won't be used
         * in the future.
         */
        bool passOnCb = parent != nullptr && parent->isTemporaryImage_;
        commandBuffer_ = passOnCb ? parent->commandBuffer_
        : [getMPSCNNContext().commandQueue commandBuffer];
        
        bool commitInputCb = parent != nullptr && !parent->isTemporaryImage_;
        if (commitInputCb) {
            parent->synchronize();
        }
        
//        const auto& isTemporaryImages =
//        op->GetRepeatedArgument<int>(kMPSCNNOutputIsTempImageArg);
//        isTemporaryImage_ = isTemporaryImages.size()
//        ? isTemporaryImages.at(output_idx)
//        : op->GetSingleArgument<int>(kMPSCNNOutputIsTempImageArg, 1);
        
        if (isTemporaryImage_) {
            image_ = createTemporaryImage(commandBuffer_, n, height, width, channels, output_idx);
        } else {
            image_ = createStaticImage(n, height, width, channels);
        }
    }
    
    void markRead() {
        if (isTemporaryImage_) {
            MPSTemporaryImage* tempImg = (MPSTemporaryImage*)image_;
            tempImg.readCount -= 1;
        }
    }
    
    MPSImage* getImage() const {
        return image_;
    }
    
    id<MTLCommandBuffer> getCommandBuffer() const {
        return commandBuffer_;
    }
    
    void synchronize() {
        // commit the command buffer if it is notEnqueued
        if (commandBuffer_ != nullptr && commandBuffer_.status == 0) {
            [commandBuffer_ commit];
        }
    }
    
    void cleanup() {
        markRead();
        synchronize();
    }
    
    void copyToOutputBlob(Blob* output) {
        output->image_ = image_;
        output->commandBuffer_ = commandBuffer_;
        output->isTemporaryImage_ = isTemporaryImage_;
    }
    
private:
    MPSImage* image_{nullptr};
    id<MTLCommandBuffer> commandBuffer_{nullptr};
    bool isTemporaryImage_ = true;
};

NSString * kernelFor(const MPSImage* X, NSString* arrayKernel, NSString* nonArrayKernel) {
    if (X.featureChannels > 4) {
        return arrayKernel;
    }
    if (X.numberOfImages > 1) {
        return arrayKernel;
    }
    return nonArrayKernel;
}

struct LaunchParams {
    MTLSize threadsPerThreadgroup;
    MTLSize threadgroupsPerGrid;
};

LaunchParams spatialPointwiseKernelLaunchParams(
                                                id<MTLComputePipelineState> pipeline,
                                                const MPSImage* im) {
    const auto maxThreadsPerThreadgroup =
    [pipeline maxTotalThreadsPerThreadgroup];
    const auto threadExecutionWidth = [pipeline threadExecutionWidth];
    const auto threadsPerThreadgroup = MTLSizeMake(
                                                   8 /* threadExecutionWidth */,
                                                   4 /* maxThreadsPerThreadgroup / threadExecutionWidth */,
                                                   1);
    const auto threadgroupsPerGrid = MTLSizeMake(
                                                 divRoundUp(im.width, threadsPerThreadgroup.width),
                                                 divRoundUp(im.height, threadsPerThreadgroup.height),
                                                 im.numberOfImages * divRoundUp(im.featureChannels, 4));
    return {threadsPerThreadgroup, threadgroupsPerGrid};
};

class CopyToMPSCNNOp final {
public:
    Blob * RunOnDevice(float * input, int n, int width, int height, int channels) {
        //inputBuffers_.resize(Inputs().size());
        MPSImageWrapper wrapper;
        
        // const auto& X = Input(i);
        // CAFFE_ENFORCE(X.ndim() > 0 && X.ndim() <= 4);
        // std::vector<TIndex> XDims = {1, 1, 1, 1};
        // XDims.assign(X.dims().begin(), X.dims().end());
        
        Timer t;
//        const auto n = XDims[0];
//        const auto width = XDims[3];
//        const auto height = XDims[2];
//        const auto channels = XDims[1];
        
        Timer copyT;
        
        int nbytes = width * height * channels * sizeof(float);
        
        if (!inputBuffer_ || inputBuffer_.length != nbytes) {
            inputBuffer_ = [getMPSCNNContext().device
                            newBufferWithLength:nbytes
                            options:MTLResourceOptionCPUCacheModeWriteCombined];
        }
        memcpy([inputBuffer_ contents], input, nbytes);
//        VLOG(2) << "CopyToMPSCNNOp input copy took: " << copyT.MilliSeconds();
        
        wrapper = MPSImageWrapper(nullptr, n, height, width, channels, 0);
        
//        if (i == 0) {
//            wrappers[i] =
//            MPSImageWrapper(this, nullptr, n, height, width, channels, i);
//        } else {
//            wrappers[i] =
//            MPSImageWrapper(this, &wrappers[0], n, height, width, channels, i);
//        }
        
        auto commandBuffer = wrapper.getCommandBuffer();
        MPSImage* output = wrapper.getImage();
        id<MTLComputeCommandEncoder> encoder =
        [commandBuffer computeCommandEncoder];
        id<MTLComputePipelineState> state =
        getMPSCNNContext().getSpecializedPipelineState(
                                                       kernelFor(
                                                                 output,
                                                                 @"copy_nchw_to_metal",
                                                                 @"copy_nchw_to_metal_nonarray"),
                                                       {{ushort(channels), ushort(height), ushort(width)}});
        [encoder setComputePipelineState:state];
        [encoder setBuffer:inputBuffer_ offset:0 atIndex:0];
        [encoder setTexture:[output texture] atIndex:0];
        const auto& launchParams =
        spatialPointwiseKernelLaunchParams(state, output);
        [encoder dispatchThreadgroups:launchParams.threadgroupsPerGrid
                threadsPerThreadgroup:launchParams.threadsPerThreadgroup];
        [encoder endEncoding];
//        VLOG(2) << "CopyToMPSCNNOp took: " << t.MilliSeconds();
        
        if(outputBlob == nullptr)
            outputBlob = new Blob();
        
        wrapper.copyToOutputBlob(outputBlob);
        
        return outputBlob;
    }
    
private:
    id<MTLBuffer> inputBuffer_;
    Blob * outputBlob;
};






auto mpsImageSize = [](MPSImage* X) {
    return X.featureChannels * X.height * X.width * X.numberOfImages;
};
class CopyFromMPSCNNOp final{
public:
    float * RunOnDevice(Blob * input, int n, int width, int height, int channels) {
        Timer t;
//        auto Wrapper = [&](size_t i) { return Inputs()[i]->template Get<MPSImageWrapper>(); };
//        auto cb = [&](size_t i) { return Wrapper(i).getCommandBuffer(); };
//        auto X = [&](size_t i) { return Wrapper(i).getImage(); };

        MPSImageWrapper wrapper;
        wrapper = MPSImageWrapper(nullptr, n, height, width, channels, 0);
        auto cb = wrapper.getCommandBuffer();
        auto X = wrapper.getImage();
        
        auto cb0 = cb;

        //CAFFE_ENFORCE_EQ(cb0, cb(i));
        //MPSImage* Xi = X(i);
        if (!outputBuffer_ || outputBuffer_.length != mpsImageSize(X) * sizeof(float)) {
            outputBuffer_ =
            [getMPSCNNContext().device newBufferWithLength:mpsImageSize(X) * sizeof(float)
                                                   options:MTLResourceOptionCPUCacheModeDefault];
        }
        id<MTLComputeCommandEncoder> encoder = [cb0 computeCommandEncoder];
        id<MTLComputePipelineState> state = getMPSCNNContext().getSpecializedPipelineState(
                                                                                           kernelFor(X, @"copy_metal_to_nchw", @"copy_metal_to_nchw_nonarray"),
                                                                                           {{ushort(X.featureChannels), ushort(X.height), ushort(X.width)}});
        
        [encoder setComputePipelineState:state];
        [encoder setBuffer:outputBuffer_ offset:0 atIndex:0];
        [encoder setTexture:[X texture] atIndex:0];
        
        const auto& launchParams = spatialPointwiseKernelLaunchParams(state, X);
        [encoder dispatchThreadgroups:launchParams.threadgroupsPerGrid
                threadsPerThreadgroup:launchParams.threadsPerThreadgroup];
        [encoder endEncoding];
        wrapper.markRead();
        
        [cb0 commit];
        [cb0 waitUntilCompleted];
        
        Timer copyOutT;
        
        if(!output) {
            output = (float *) malloc(128 * 128 * 3 * sizeof(float));
        }
        
        memcpy(output, [outputBuffer_ contents], outputBuffer_.length);
        
//        Output(i)->Resize(Xi.numberOfImages, Xi.featureChannels, Xi.height, Xi.width);
//        Output(i)->mutable_data<float>();
//        CAFFE_ENFORCE_EQ(outputBuffers_[i].length, Output(i)->nbytes());
//        memcpy(
//               Output(i)->mutable_data<float>(), [outputBuffer contents], outputBuffer.length);
//        VLOG(2) << "CopyFromMPSCNNOp memcpy took: " << copyOutT.MilliSeconds();
//
//        VLOG(2) << "CopyFromMPSCNNOp took: " << t.MilliSeconds();
        return output;
    }
    
private:
    id<MTLBuffer> outputBuffer_;
    float * output;
};
