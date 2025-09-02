gen:
	@which xcodegen >/dev/null 2>&1 || (echo "xcodegen not found. Install via: brew install xcodegen" && exit 1)
	xcodegen generate --use-cache

open:
	@open DoubleExposureCamera.xcodeproj

