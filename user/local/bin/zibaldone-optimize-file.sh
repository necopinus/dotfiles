#!/bin/bash

# Image optimization helper script. Expects the following packages
# (Ubuntu) or equivalents to be installed:
#
#     graphicsmagick
#     libjpeg-turbo-progs
#     optipng

# Constrain image to the following maximum dimension. (This has been
# chosen so that all of my current image scale to ≤ ~1 MB in size.)
#
SIZE=1200

# Asset locations
#
ASSETS_LIVE="$HOME/OneDrive/DelphiStrategy/Zibaldone/📦 Assets"
ASSETS_BACK="$HOME/OneDrive/DelphiStrategy/Zibaldone (Original 📦 Assets)"

# Parse commandline
#
NEED_HELP="no"
case "$1" in
	rgb)
		GRAYSCALE="no"
		;;
	grayscale)
		GRAYSCALE="yes"
		;;
	*)
		NEED_HELP="yes"
		;;
esac
if [[ -f "$2" ]]; then
	FILE_LIVE="$(readlink -f "$2")"
	if [[ "$(dirname "$FILE_LIVE")" == "$ASSETS_LIVE" ]] && [[ "$(basename "$2")" == "$(basename "$FILE_LIVE")" ]]; then
		FILE_BACK="$ASSETS_BACK/$(basename "$FILE_LIVE")"
	else
		NEED_HELP="yes"
	fi
else
	NEED_HELP="yes"
fi

if [[ "$NEED_HELP" == "yes" ]]; then
	echo "USAGE: zibaldone-optimize-file.sh [rgb|grayscale] <FILE>"
	echo ""
	echo "Outputs a color (rgb) or grayscale (grayscale) JPEG (jpg) optimized"
	echo "version of FILE that has been scaled down (if appropriate) so that its"
	echo "smallest dimension is ${SIZE}px."
	echo ""
	echo "If a PNG (png) file is supplied, losslessly optimize it."
	echo ""
	echo "The original image will be copied to the original assets directory:"
	echo ""
	echo "    $ASSETS_BACK"
	echo ""
	echo "Non-JPEG, non-PNG files will be copied unchanged. Already optimized or"
	echo "copied files will be ignored."
	exit 1
fi

# Determine GraphicsMagick and CJPEG commands.
#
if [[ "$GRAYSCALE" == "yes" ]]; then
	CONVERT="$(which gm) convert -colorspace Rec709Luma"
	CJPEG="$(which cjpeg) -grayscale"
else
	CONVERT="$(which gm) convert"
	CJPEG="$(which cjpeg)"
fi

# Optimize image.
#
if [[ ! -f "$FILE_BACK" ]]; then
	if [[ "${FILE_LIVE: -4}" == ".jpg" ]]; then
		mv -v "$FILE_LIVE" "$FILE_BACK"
		bash -c "$CONVERT -resize '${SIZE}x${SIZE}^>' -strip '$FILE_BACK' TGA:- | $CJPEG -optimize -progressive -outfile '$FILE_LIVE'"
	elif [[ "${FILE_LIVE: -4}" == ".png" ]]; then
		optipng -o7 "$FILE_LIVE"
		cp -v "$FILE_LIVE" "$FILE_BACK"
	else
		cp -v "$FILE_LIVE" "$FILE_BACK"
	fi
fi
