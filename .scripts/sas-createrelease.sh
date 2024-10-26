#! /bin/bash

#
# Create a SAS macro release
#
#
#

echo $@

# -- identify commiit
echo "Processing commit ${GITHUB_SHA}"


# -- identify reference
echo "Reference ${GITHUB_REF}"


# -- generate release label 
RELEASE_SHORT_LABEL=${VARS_COMPONENT}_$( echo ${GITHUB_REF_NAME} | tr -d v ).zip
RELEASE_LONG_LABEL=${RELEASE_SHORT_LABEL}-${GITHUB_SHA}.zip


# -- create archive
cd /src

echo "-- create archive ${RELEASE_LONG_LABEL}"
zip -r ../${RELEASE_LONG_LABEL} -x '.keep' $@

echo "-- create archive ${RELEASE_SHORT_LABEL}"
cp ../${RELEASE_LONG_LABEL} ../${RELEASE_SHORT_LABEL}

ls -alF /


# -- create release as draft

echo "-- create draft release"

echo "curl -sS -L -X POST -H \"Accept: application/vnd.github+json\" -H \"Authorization: Bearer ${ACTION_TOKEN}\" -H \"X-GitHub-Api-Version: 2022-11-28\" ${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/releases -d '{\"tag_name\":\"${GITHUB_REF_NAME}\",\"target_commitish\":\"${GITHUB_SHA}\",\"name\":\"${GITHUB_REF_NAME}\",\"body\":\"Description of the release\",\"draft\":true,\"prerelease\":false,\"generate_release_notes\":false}'"


RELEASE_CREATE=$( curl -sS -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${ACTION_TOKEN}" -H "X-GitHub-Api-Version: 2022-11-28" \
                       ${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/releases \
                      -d "{\"tag_name\":\"${GITHUB_REF_NAME}\", \"name\":\"${GITHUB_REF_NAME}\", \"body\":\"Description of the release\",\"draft\":true, \"prerelease\":false, \"generate_release_notes\":false}" )


# -- identify release ID
RELEASE_ID=$( echo ${RELEASE_CREATE} | jq -r .id )

echo "${RELEASE_ID}"


# -- identify upload url
RELEASE_UPLOAD_URL=$( echo ${RELEASE_CREATE} | jq -r .upload_url )
RELEASE_UPLOAD_URL="${RELEASE_UPLOAD_URL%\{*}"


# -- add assets

curl -sS -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${ACTION_TOKEN}" -H "X-GitHub-Api-Version: 2022-11-28" \
        --data-binary @../${RELEASE_SHORT_LABEL}  \
        $RELEASE_UPLOAD_URL?name=${RELEASE_SHORT_LABEL}

#curl -sS -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer <YOUR-TOKEN>" -H "X-GitHub-Api-Version: 2022-11-28" -H "Content-Type: application/octet-stream" \
#     "https://uploads.github.com/repos/OWNER/REPO/releases/RELEASE_ID/assets?name=example.zip" \
#     --data-binary "@example.zip"


# -- set release as final








