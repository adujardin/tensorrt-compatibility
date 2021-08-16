# TensorRT Docker

The goal of this project is to test model against all version of tensorRT easily to assess compatiblity.

## Will it run with TRT X.Y ?

The test script is still quite basic, and requires the model to be put in the current folder.

Example :

```sh
wget https://raw.githubusercontent.com/adujardin/tensorrt-compatibility/master/check_onnx_model.sh
bash check_onnx_model.sh model.onnx --fp16
Testing TensorRT...
 5.1
 6.0
 7.0
 7.1
 7.2

=====================================================

TensorRT 5.1 FAILED 
TensorRT 6.0 PASSED 
TensorRT 7.0 PASSED 
TensorRT 7.1 PASSED 
TensorRT 7.2 PASSED 

For more information :
  cat log_model.onnx.txt

```

By default the script will check against TRT 7.0 -> 8.0 ( = JetPack 4.4 and above).

The logs are displayed in real time and stored into log files, including runtimes (like "log_trt5.1_model.onnx.txt"). Since this is the stock version of trtexec, the logging isn't consistent between version and quite verbose unfortunetly. It's currently not possible to have a output like "TRT 6.0 : Compatible, took N ms (median, end to end)".

## Support

Currently supporting TensorRT versions:  

```
4.0, 5.0, 5.1, 6.0, 7.0, 7.1, 7.2 8.0
```

The docker image used are now taken from nvidia NGC https://ngc.nvidia.com/catalog/containers/nvidia:tensorrt
