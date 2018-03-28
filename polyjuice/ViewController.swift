//
//  ViewController.swift
//  polyjuice
//
//  Created by DJ on 2018. 3. 7..
//  Copyright © 2018년 DJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let testImg = "000001.jpg"
    let testImg2 = "065084.jpg"
    @IBOutlet weak var personImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Initializing ...")
        self.personImage.image=UIImage(named: testImg)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func convertButton(_ sender: UIButton) {
        self.personImage.image=UIImage(named: testImg2)
        
    }
    
}







//nearestOp->RunOnDevice(f_input_chw_buf, f_input_64_chw_buf, 1, 3, 128, 128);
//nearestOp->RunOnDevice(f_input_64_chw_buf, f_input_32_chw_buf, 1, 3, 64, 64);
//nearestOp->RunOnDevice(f_input_32_chw_buf, f_input_16_chw_buf, 1, 3, 32, 32);
//nearestOp->RunOnDevice(f_input_16_chw_buf, f_input_8_chw_buf, 1, 3, 16, 16);
//
//output_8     = copyToOpenGLOp_8->CopyToOpenGL(f_input_8_chw_buf, 8  , 8  , 3);
//output_16    = copyToOpenGLOp_16->CopyToOpenGL(f_input_16_chw_buf, 16 , 16 , 3);
//output_32    = copyToOpenGLOp_32->CopyToOpenGL(f_input_32_chw_buf, 32 , 32 , 3);
//output_64    = copyToOpenGLOp_64->CopyToOpenGL(f_input_64_chw_buf, 64 , 64 , 3);
//output_128   = copyToOpenGLOp_128->CopyToOpenGL(f_input_chw_buf, 128, 128, 3);
//
//output_8 = conv_8_32_3x3_0    ->RunOnDeviceWithOrderNCHW(*output_8, w["cnv_w_32_8_3x3_0"], channel, k_size, k_size, w["cnv_b_32_8_3x3_0"], prelu, channel, 1, 1, 1, 1, 8, 8, tiling, 0);
//output_8 = conv_8_32_3x3_1    ->RunOnDeviceWithOrderNCHW(*output_8, w["cnv_w_32_8_3x3_1"], channel, k_size, k_size, w["cnv_b_32_8_3x3_1"], prelu, channel, 1, 1, 1, 1, 8, 8, tiling, 0);
//output_8 = conv_8_32_1x1      ->RunOnDeviceWithOrderNCHW(*output_8, w["cnv_w_32_8_1x1"],   channel, 1, 1, w["cnv_b_32_8_1x1"],   prelu, channel, 0, 0, 1, 1, 8, 8, tiling, 0);
//
//output_16 = conv_16_32_3x3_0   ->RunOnDeviceWithOrderNCHW(*output_16, w["cnv_w_32_16_3x3_0"], channel, k_size, k_size, w["cnv_b_32_16_3x3_0"], prelu, channel, 1, 1, 1, 1, 16, 16, tiling, 0);
//output_16 = conv_16_32_3x3_1   ->RunOnDeviceWithOrderNCHW(*output_16, w["cnv_w_32_16_3x3_1"], channel, k_size, k_size, w["cnv_b_32_16_3x3_1"], prelu, channel, 1, 1, 1, 1, 16, 16, tiling, 0);
//output_16 = conv_16_32_1x1     ->RunOnDeviceWithOrderNCHW(*output_16, w["cnv_w_32_16_1x1"],   channel, 1, 1, w["cnv_b_32_16_1x1"],   prelu, channel, 0, 0, 1, 1, 16, 16, tiling, 0);
//
//output_32 = conv_32_32_3x3_0   ->RunOnDeviceWithOrderNCHW(*output_32, w["cnv_w_32_32_3x3_0"], channel, k_size, k_size, w["cnv_b_32_32_3x3_0"], prelu, channel, 1, 1, 1, 1, 32, 32, tiling, 0);
//output_32 = conv_32_32_3x3_1   ->RunOnDeviceWithOrderNCHW(*output_32, w["cnv_w_32_32_3x3_1"], channel, k_size, k_size, w["cnv_b_32_32_3x3_1"], prelu, channel, 1, 1, 1, 1, 32, 32, tiling, 0);
//output_32 = conv_32_32_1x1     ->RunOnDeviceWithOrderNCHW(*output_32, w["cnv_w_32_32_1x1"],   channel, 1, 1, w["cnv_b_32_32_1x1"],   prelu, channel, 0, 0, 1, 1, 32, 32, tiling, 0);
//
//output_64 = conv_64_32_3x3_0   ->RunOnDeviceWithOrderNCHW(*output_64, w["cnv_w_32_64_3x3_0"], channel, k_size, k_size, w["cnv_b_32_64_3x3_0"], prelu, channel, 1, 1, 1, 1, 64, 64, tiling, 0);
//output_64 = conv_64_32_3x3_1   ->RunOnDeviceWithOrderNCHW(*output_64, w["cnv_w_32_64_3x3_1"], channel, k_size, k_size, w["cnv_b_32_64_3x3_1"], prelu, channel, 1, 1, 1, 1, 64, 64, tiling, 0);
//output_64 = conv_64_32_1x1     ->RunOnDeviceWithOrderNCHW(*output_64, w["cnv_w_32_64_1x1"],   channel, 1, 1, w["cnv_b_32_64_1x1"],   prelu, channel, 0, 0, 1, 1, 64, 64, tiling, 0);
//
//output_128 = conv_128_32_3x3_0  ->RunOnDeviceWithOrderNCHW(*output_128, w["cnv_w_32_128_3x3_0"], channel, k_size, k_size, w["cnv_b_32_128_3x3_0"], prelu, channel, 1, 1, 1, 1, 128, 128, tiling, 0);
//output_128 = conv_128_32_3x3_1  ->RunOnDeviceWithOrderNCHW(*output_128, w["cnv_w_32_128_3x3_1"], channel, k_size, k_size, w["cnv_b_32_128_3x3_1"], prelu, channel, 1, 1, 1, 1, 128, 128, tiling, 0);
//output_128 = conv_128_32_1x1    ->RunOnDeviceWithOrderNCHW(*output_128, w["cnv_w_32_128_1x1"],   channel, 1, 1, w["cnv_b_32_128_1x1"],   prelu, channel, 0, 0, 1, 1, 128, 128, tiling, 0);
//
//output = resize_16          ->RunOnDevice(*output_8);
//output = concat_64          ->RunOnDevice(*output, *output_16);
//output =  dep_16_64_3x3_0    ->RunOnDeviceWithOrderNCHW(*output, w["dep_w_16_16_16_0_5"], 32, dep_k_size, dep_k_size, w["dep_b_16_16_16_0_5"], prelu, 32, 1, 1, 1, 1, 16, 16, tiling, 0);
//output = conv_16_64_3x3_0    ->RunOnDeviceWithOrderNCHW(*output, w["pnt_w_16_16_16_0_5"], 16, pnt_k_size, pnt_k_size, w["pnt_b_16_16_16_0_5"], prelu, 16, 0, 0, 1, 1, 16, 16, tiling, 0);
//output =  dep_16_64_3x3_1    ->RunOnDeviceWithOrderNCHW(*output, w["dep_w_16_16_16_1_5"], 16, dep_k_size, dep_k_size, w["dep_b_16_16_16_1_5"], prelu, 16, 1, 1, 1, 1, 16, 16, tiling, 0);
//output = conv_16_64_3x3_1    ->RunOnDeviceWithOrderNCHW(*output, w["pnt_w_16_16_16_1_5"], 16, pnt_k_size, pnt_k_size, w["pnt_b_16_16_16_1_5"], prelu, 16, 0, 0, 1, 1, 16, 16, tiling, 0);
//output = conv_16_64_1x1      ->RunOnDeviceWithOrderNCHW(*output, w["obo_w_16_16_16_5"]  , 16, obo_k_size, obo_k_size, w["obo_b_16_16_16_5"], prelu, 16, 0, 0, 1, 1, 16, 16, tiling, 0);
//
//output = resize_32          ->RunOnDevice(*output);
//output = concat_96          ->RunOnDevice(*output, *output_32);
//output =  dep_32_96_3x3_0    ->RunOnDeviceWithOrderNCHW(*output, w["dep_w_24_24_32_0_6"], 32, dep_k_size, dep_k_size, w["dep_b_24_24_32_0_6"], prelu, 32, 1, 1, 1, 1, 32, 32, tiling, 0);
//output = conv_32_96_3x3_0    ->RunOnDeviceWithOrderNCHW(*output, w["pnt_w_24_24_32_0_6"], 24, pnt_k_size, pnt_k_size, w["pnt_b_24_24_32_0_6"], prelu, 24, 0, 0, 1, 1, 32, 32, tiling, 0);
//output =  dep_32_96_3x3_1    ->RunOnDeviceWithOrderNCHW(*output, w["dep_w_24_24_32_1_6"], 24, dep_k_size, dep_k_size, w["dep_b_24_24_32_1_6"], prelu, 24, 1, 1, 1, 1, 32, 32, tiling, 0);
//output = conv_32_96_3x3_1    ->RunOnDeviceWithOrderNCHW(*output, w["pnt_w_24_24_32_1_6"], 24, pnt_k_size, pnt_k_size, w["pnt_b_24_24_32_1_6"], prelu, 24, 0, 0, 1, 1, 32, 32, tiling, 0);
//output = conv_32_96_1x1      ->RunOnDeviceWithOrderNCHW(*output, w["obo_w_24_24_32_6"]  , 24, obo_k_size, obo_k_size, w["obo_b_24_24_32_6"], prelu, 24, 0, 0, 1, 1, 32, 32, tiling, 0);
//
//output = resize_64          ->RunOnDevice(*output);
//output = concat_128         ->RunOnDevice(*output, *output_64);
//output =  dep_64_128_3x3_0    ->RunOnDeviceWithOrderNCHW(*output, w["dep_w_32_32_64_0_7"], 40, dep_k_size, dep_k_size, w["dep_b_32_32_64_0_7"], prelu, 48, 1, 1, 1, 1, 64, 64, tiling, 0);
//output = conv_64_128_3x3_0    ->RunOnDeviceWithOrderNCHW(*output, w["pnt_w_32_32_64_0_7"], 32, pnt_k_size, pnt_k_size, w["pnt_b_32_32_64_0_7"], prelu, 32, 0, 0, 1, 1, 64, 64, tiling, 0);
//output =  dep_64_128_3x3_1    ->RunOnDeviceWithOrderNCHW(*output, w["dep_w_32_32_64_1_7"], 32, dep_k_size, dep_k_size, w["dep_b_32_32_64_1_7"], prelu, 32, 1, 1, 1, 1, 64, 64, tiling, 0);
//output = conv_64_128_3x3_1    ->RunOnDeviceWithOrderNCHW(*output, w["pnt_w_32_32_64_1_7"], 32, pnt_k_size, pnt_k_size, w["pnt_b_32_32_64_1_7"], prelu, 32, 0, 0, 1, 1, 64, 64, tiling, 0);
//output = conv_64_128_1x1      ->RunOnDeviceWithOrderNCHW(*output, w["obo_w_32_32_64_7"]  , 32, obo_k_size, obo_k_size, w["obo_b_32_32_64_7"], prelu, 32, 0, 0, 1, 1, 64, 64, tiling, 0);
//
//output = resize_128         ->RunOnDevice(*output);
//output = concat_160         ->RunOnDevice(*output, *output_128);
//output =  dep_128_160_3x3_0    ->RunOnDeviceWithOrderNCHW(*output, w["dep_w_40_40_128_0_8"], 48, dep_k_size, dep_k_size, w["dep_b_40_40_128_0_8"], prelu, 48, 1, 1, 1, 1, 128, 128, tiling, 0);
//output = conv_128_160_3x3_0    ->RunOnDeviceWithOrderNCHW(*output, w["pnt_w_40_40_128_0_8"], 40, pnt_k_size, pnt_k_size, w["pnt_b_40_40_128_0_8"], prelu, 40, 0, 0, 1, 1, 128, 128, tiling, 0);
//output =  dep_128_160_3x3_1    ->RunOnDeviceWithOrderNCHW(*output, w["dep_w_40_40_128_1_8"], 40, dep_k_size, dep_k_size, w["dep_b_40_40_128_1_8"], prelu, 40, 1, 1, 1, 1, 128, 128, tiling, 0);
//output = conv_128_160_3x3_1    ->RunOnDeviceWithOrderNCHW(*output, w["pnt_w_40_40_128_1_8"], 40, pnt_k_size, pnt_k_size, w["pnt_b_40_40_128_1_8"], prelu, 40, 0, 0, 1, 1, 128, 128, tiling, 0);
//output = conv_128_160_1x1      ->RunOnDeviceWithOrderNCHW(*output, w["obo_w_40_40_128_8"]  , 40, obo_k_size, obo_k_size, w["obo_b_40_40_128_8"], prelu, 40, 0, 0, 1, 1, 128, 128, tiling, 0);
//
//output = conv_last          ->RunOnDeviceWithOrderNCHW(*output, w["obo_w_40_3_128_9"], 3, 1, 1, w["obo_b_40_3_128_9"], nullptr, 0, 0, 0, 1, 1, 128, 128, tiling, 0);

