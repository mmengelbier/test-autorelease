#! /bin/bash

#
# Create a SAS macro release
#
#
#



# -- identify commiit
echo "Processing commit ${GITHUB_SHA}"


# -- identify reference
echo "Reference ${GITHUB_REF}"


# -- generate release label 
RELEASE_STRING="${VARS_COMPONENT}_$( echo ${GITHUB_REF_NAME} | tr -d v )-${GITHUB_SHA}"

echo "${RELEASE_STRING}"


# -- identify folders to include
cd /src

gzip -r ../${RELEASE_STRING}.zip $(ls)

ls -alF /





