//
//  mpscnn_context.h
//  polyjuice
//
//  Created by DJ on 2018. 3. 7..
//  Copyright © 2018년 DJ. All rights reserved.
//

#ifndef mpscnn_context_h
#define mpscnn_context_h

#import <Metal/MTLBuffer.h>
#import <Metal/MTLDevice.h>
#import <Metal/MTLLibrary.h>

#include <array>
#include <vector>
#include <mutex>
#include <string>
#include <thread>
#include <unordered_map>

struct MPSCNNContext {
public:
    id<MTLDevice> device;
    id<MTLCommandQueue> commandQueue;
    id<MTLLibrary> library;
    
    id<MTLComputePipelineState> getPipelineState(NSString* kernel);
    id<MTLComputePipelineState> getSpecializedPipelineState(NSString* kernel,
                                                            const std::vector<ushort>& constants);
    
private:
    std::mutex pipelineCacheMutex_;
    std::unordered_map<std::string, id<MTLComputePipelineState>> pipelineCache_;
};

MPSCNNContext& getMPSCNNContext();

#endif /* mpscnn_context_h */
