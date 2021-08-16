#!/usr/bin/env bash

if [ $# -eq 0 ];  then
    echo "Usage : check_onnx_model.sh model_file.onnx [trtexec options like --fp16 or --workspace=2000...]"
    exit 1
fi

MODEL_PATH="$1"
# By default mount the current folder
VOLUME_HOST="$(pwd)"
VOLUME_DOCKER="/host_volume"
TRTEXEC_ARGS="--onnx=$VOLUME_DOCKER/$MODEL_PATH"

DOCKER_IMAGE_OLDER="adujardin/tensorrt-trtexec:"

declare -A hashmap
#hashmap["4.0"]="${DOCKER_IMAGE_OLDER}4.0"
hashmap["4.0"]="nvcr.io/nvidia/tensorrt:18.06-py3"
#hashmap["5.0"]="${DOCKER_IMAGE_OLDER}5.0"
hashmap["5.0"]="nvcr.io/nvidia/tensorrt:18.10-py3"
#hashmap["5.1"]="${DOCKER_IMAGE_OLDER}5.1"
hashmap["5.1"]="nvcr.io/nvidia/tensorrt:19.03-py3"
#hashmap["6.0"]="${DOCKER_IMAGE_OLDER}6.0"
hashmap["6.0"]="nvcr.io/nvidia/tensorrt:19.09-py3"
#hashmap["7.0"]="${DOCKER_IMAGE_OLDER}7.0"
hashmap["7.0"]="nvcr.io/nvidia/tensorrt:20.02-py3"
hashmap["7.1"]="nvcr.io/nvidia/tensorrt:20.07-py3"
hashmap["7.2"]="nvcr.io/nvidia/tensorrt:20.11-py3"
hashmap["8.0"]="nvcr.io/nvidia/tensorrt:21.07-py3"

TRT_COMMAND=""

declare -A hashmap_jp
hashmap_jp["4.0"]="3.3"
hashmap_jp["5.0"]="4.1.1, 4.2.0"
hashmap_jp["5.1"]="4.2.1"
hashmap_jp["6.0"]="4.3"
hashmap_jp["7.0"]=""
hashmap_jp["7.1"]="4.4.X, 4.5.X"
hashmap_jp["7.2"]=""
hashmap_jp["8.0"]="4.6.X"

# JP 3.3 : TRT 4.0
# JP 4.1.1 : TRT 5.0
# JP 4.2.0 : TRT 5.0
# JP 4.2.1 : TRT 5.1
# JP 4.3 : TRT 6.0
# JP 4.4 : TRT 7.1

#trt_versions=( "4.0" "5.0" "5.1" "6.0" "7.0" )
trt_versions=( "7.0" "7.1" "7.2" "8.0" )
 echo -e "Testing TensorRT..."

for version in "${trt_versions[@]}"; do
    echo -e " ${version}"

    docker_container="${hashmap[${version}]}"
    if [[ $docker_container == *"nvcr.io/nvidia"* ]]; then
        TRT_COMMAND="trtexec"
    else
        TRT_COMMAND=""
    fi

    docker run --gpus all -v "$VOLUME_HOST:$VOLUME_DOCKER":ro $docker_container $TRT_COMMAND $TRTEXEC_ARGS 2>&1 | tee "log_trt${version}_${MODEL_PATH}.txt" #&> "log_trt${version}_${MODEL_PATH}.txt"
done

echo -e "\n=====================================================\n"

fail_str="&&&& FAILED TensorRT.trtexec"
ok_str="&&&& PASSED TensorRT.trtexec"
log_file="log_${MODEL_PATH}.txt"
raw_log_file="rawlog_${MODEL_PATH}.txt"

for version in "${trt_versions[@]}"; do
    in_log_file="log_trt${version}_${MODEL_PATH}.txt"
    echo -e "\n\n==================== TensorRT ${version} ===================\n" >> "${log_file}"
    echo -e "\n\n==================== TensorRT ${version} ===================\n" >> "${raw_log_file}"
    tail -n 20 "${in_log_file}" >> "${log_file}"
    cat "${in_log_file}" >> "${raw_log_file}"

    if grep -q "${ok_str}" "${in_log_file}"; then
        printf "\033[32m PASSED \033[39m"
    else
        printf "\033[31m FAILED \033[39m"
    fi

    jp_ver_str="${hashmap_jp[${version}]}"
    display_str="TensorRT ${version}"
    if [ -z "${jp_ver_str}" ]; then
        echo -en "${display_str}\n"
    else
        echo -en "${display_str} (JetPack ${jp_ver_str})\n"
    fi


    rm "${in_log_file}"
done

# Verbose
#cat "log_${MODEL_PATH}.txt"
echo -e "\nFor more information :\n  cat ${log_file}\n"
