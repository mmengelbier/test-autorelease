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

# -- generate release labels 
RELEASE_SHORT_LABEL=${VARS_COMPONENT}_$( echo ${GITHUB_REF_NAME} | tr -d v )
RELEASE_LONG_LABEL=${RELEASE_SHORT_LABEL}-${GITHUB_SHA}



# -- scaffolding
mkdir /archives

# -- change working directory
cd /src


# -- create Zip archive

echo "-- create Zip archive ${RELEASE_LONG_LABEL}"
zip -r /archives/${RELEASE_LONG_LABEL}.zip $@


echo "-- create tar.gz archive ${RELEASE_LONG_LABEL}"
tar -cf /archives/${RELEASE_LONG_LABEL}.tar $@
gzip /archives/${RELEASE_LONG_LABEL}.tar


echo "-- create archives for ${RELEASE_SHORT_LABEL}"
cp /archives/${RELEASE_LONG_LABEL}.zip /archives/${RELEASE_SHORT_LABEL}.zip
cp /archives/${RELEASE_LONG_LABEL}.tar.gz /archives/${RELEASE_SHORT_LABEL}.tar.gz


ls -alF /archives


# -- create release as draft

echo "-- create draft release"

echo "curl -sS -L -X POST -H \"Accept: application/vnd.github+json\" -H \"Authorization: Bearer ${ACTION_TOKEN}\" -H \"X-GitHub-Api-Version: 2022-11-28\" ${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/releases -d '{\"tag_name\":\"${GITHUB_REF_NAME}\",\"target_commitish\":\"${GITHUB_SHA}\",\"name\":\"${GITHUB_REF_NAME}\",\"body\":\"Description of the release\",\"draft\":true,\"prerelease\":false,\"generate_release_notes\":false}'"


RELEASE_CREATE=$( curl -sS -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${ACTION_TOKEN}" -H "X-GitHub-Api-Version: 2022-11-28" \
                       ${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/releases \
                      -d "{\"tag_name\":\"${GITHUB_REF_NAME}\", \"name\":\"${GITHUB_REF_NAME}\", \"body\":\"Description of the release\",\"draft\":true, \"prerelease\":true, \"generate_release_notes\":false}" )


# -- identify release ID
RELEASE_ID=$( echo ${RELEASE_CREATE} | jq -r .id )

echo "${RELEASE_ID}"


# -- identify upload url
RELEASE_UPLOAD_URL=$( echo ${RELEASE_CREATE} | jq -r .upload_url )
RELEASE_UPLOAD_URL="${RELEASE_UPLOAD_URL%\{*}"


# -- add assets

echo "-- add release assets"

for XFILE in "$(ls /archives)"; do

   echo "   adding file ${XFILE}"

   curl -sS -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${ACTION_TOKEN}" -H "X-GitHub-Api-Version: 2022-11-28" -H "Content-Type: application/octet-stream" \
           --data-binary @/archives/${XFILE}  \
           $RELEASE_UPLOAD_URL?name=${XFILE}

done



#curl -sS -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${ACTION_TOKEN}" -H "X-GitHub-Api-Version: 2022-11-28" -H "Content-Type: application/octet-stream" \
#        --data-binary @/${RELEASE_LONG_LABEL}  \
#        $RELEASE_UPLOAD_URL?name=${RELEASE_LONG_LABEL}


# -- set release as final
curl -sS -L -X PATCH -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${ACTION_TOKEN}" -H "X-GitHub-Api-Version: 2022-11-28" \
                       ${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/releases/${RELEASE_ID} \
                      -d "{\"draft\":false, \"prerelease\":false, \"make_latest\":true}" 







