# TensorRT Docker

The goal of this project is to test model against all version of tensorRT easily to assess compatiblity.

## Will it run with TRT X.Y ?

The test script is still quite basic, and requires the model to be put in the current folder.

Example :

```sh
./check_onnx_model.sh model.onnx --fp16
Testing TensorRT...
 5.1
 6.0
 7.0

=====================================================

TensorRT 5.1 FAILED 
TensorRT 6.0 PASSED 
TensorRT 7.0 PASSED 
TensorRT 7.1 PASSED 

For more information :
  cat log_model.onnx.txt

```

By default the script will check against TRT 5.1 -> 7.1 ( = JetPack 4.2.1 and above).

The logs are displayed in real time and stored into log files (like "log_trt5.1_model.onnx.txt"). Since this is the stock version of trtexec, the logging isn't consistent between version and quite verbose unfortunetly. It's currently not possible to have a output like "TRT 6.0 : Compatible, took N ms (median, end to end)".

## Support

Currently supporting TensorRT versions:  

```
4.0, 5.0, 5.1, 6.0, 7.0, 7.1
```

The docker image used are now taken from nvidia NGC https://ngc.nvidia.com/catalog/containers/nvidia:tensorrt
