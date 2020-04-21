function extract-docker-image
	set REPO $argv[1]
	set TO $argv[2]
	set STRIP $argv[3]

	# We need a token, even if we don't have to authenticate.
	set TOKEN (http "https://auth.docker.io/token?service=registry.docker.io&scope=repository:$REPO:pull" | \
		jq -r '.token')
	
	# Get our image list
	set IMAGES (http "https://registry.hub.docker.com/v2/$REPO/manifests/latest" "Authorization: Bearer $TOKEN" | \
		jq -r '.fsLayers[].blobSum')
	
	# For each image, download it and tar it to the location expected stripping the first component.
	for IMAGE in $IMAGES
		http -F GET "https://registry.hub.docker.com/v2/$REPO/blobs/$IMAGE" "Authorization: Bearer $TOKEN" | \
			tar -C $TO --strip-components=$STRIP -xz
	end
end
