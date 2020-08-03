#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Please provides absolute path with all the TensorRT archives"
fi

arrayName=($(ls "${1}"/TensorRT*.*))
working_folder="${1}/repack"
mkdir -p "${working_folder}"

echo -e "The smaller archives will be exported in ${working_folder}\n"

for original_archive in "${arrayName[@]}"; do
    echo $original_archive
    filename_=$(basename -- "$original_archive")
    extension_="${filename_##*.}"
    if [ "$extension_" == "zip" ] ; then
        unzip -qq "${original_archive}" -d "${working_folder}/"
    else
        tar -xzf "${original_archive}" -C "${working_folder}/"
    fi

    extracted_folder=$(ls -1 -d ${working_folder}/*/)
    extracted_folder=${extracted_folder%?}; # remove trailing '/'

    original_folder="${extracted_folder}_original"
    mv "${extracted_folder}" "${original_folder}"

    mkdir -p "${extracted_folder}"/lib
    mkdir -p "${extracted_folder}"/include
    mkdir -p "${extracted_folder}"/bin

    mv "${original_folder}"/bin/*exec "${extracted_folder}"/bin/
    mv "${original_folder}"/lib/stubs "${extracted_folder}"/lib/
    mv "${original_folder}"/lib/*nvinfer*.so* "${extracted_folder}"/lib/
    mv "${original_folder}"/lib/*myelin*.so* "${extracted_folder}"/lib/
    mv "${original_folder}"/lib/*parser*.so* "${extracted_folder}"/lib/
    mv "${original_folder}"/include/NvInfer* "${extracted_folder}"/include/
    mv "${original_folder}"/include/NvOnnx* "${extracted_folder}"/include/
    echo "${original_archive}" > "${extracted_folder}"/version.txt

    rm -rf "${original_folder}"

    f="$(basename -- $original_archive)"
    f="${f%.zip}"
    f="${f%.tar.gz}"
 
    pushd "${extracted_folder}/.." > /dev/null
    extracted_folder=$(ls -1 -d TensorRT*/)
    #zip -qq --symlinks "${working_folder}/${f}.zip" -r "${extracted_folder}"
    tar -czf "${working_folder}/${f}.tar.gz" "${extracted_folder}"
    rm -rf "${extracted_folder}"
    popd > /dev/null

done