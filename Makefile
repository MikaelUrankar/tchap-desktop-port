PORTNAME=	tchap-desktop
DISTVERSION=	4.19.3
CATEGORIES=	net-im
MASTER_SITES=	https://github.com/${GH_ACCOUNT}/${PORTNAME}/archive/refs/tags/ \
		https://github.com/tchapgouv/tchap-web-v4/releases/download/tchap-${DISTVERSION}/:web
DISTFILES=	tchap-${DISTVERSION}.tar.gz \
		tchap-${DISTVERSION}-prod-${WEB_ARCHIVE_DATE}.tar.gz:web

MAINTAINER=	mikael@FreeBSD.org
COMMENT=	La messagerie instantanee du secteur public
WWW=		https://www.tchap.gouv.fr/

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENCE

LIB_DEPENDS=	libdbus-1.so:devel/dbus \
		libsoup-3.0.so:devel/libsoup3 \
		libwebkit2gtk-4.1.so:www/webkit2-gtk@41

USES=		cargo gmake gnome pkgconfig ssl
USE_GNOME=	atk cairo gdkpixbuf glib20 gtk30 pango

GH_ACCOUNT=	tchapgouv

CARGO_CARGOTOML=${CARGO_WRKSRC}/src-tauri/Cargo.toml
CARGO_CARGOLOCK=${CARGO_WRKSRC}/src-tauri/Cargo.lock

# https://github.com/tchapgouv/tchap-desktop/blob/tchap-4.19.2/package.json: tchap-web_archive_name
WEB_ARCHIVE_DATE=	20260401

# npm run fetch-package -- prod
# -> scripts/fetch-package.ts
# PACKAGE_URL_PREFIX = https://github.com/tchapgouv/tchap-web-v4/releases/download/
# PACKAGE_URL_PREFIX + `tchap-${targetVersion}` + "/" + filename;
#    const targetVersion: string | undefined =
#        (config[TCHAP_ENV] as TchapConfigEnv)["tchap-web_version"];
#      const filename: string | undefined =
#        (config[TCHAP_ENV] as TchapConfigEnv)["tchap-web_archive_name"];
#
# egrep "tchap-web_version|tchap-web_archive_name" work/tchap-desktop-4.19.1/package.json
# tchap-web_version = DISTVERSION
# tchap-web_archive_name = tchap-4.19.1-prod-20260311.tar.gz
#
# https://github.com/tchapgouv/tchap-web-v4/releases/download/tchap-4.19.1/tchap-4.19.1-prod-20260311.tar.gz
#
# extract it to src (tar  --strip-components 1 -xf /usr/ports/distfiles/tchap-4.19.1-prod-20260311.tar.gz -C src)

PLIST_FILES=	bin/tchap-desktop

post-extract:
	${MV} ${WRKDIR}/tchap-desktop-tchap-${DISTVERSION}/* ${WRKDIR}/tchap-desktop-${DISTVERSION}
	${MV} ${WRKDIR}/dist/* ${WRKDIR}/tchap-desktop-${DISTVERSION}/src/

do-install:

# # runtime issue, install a shell script instead?
# # from https://github.com/OrcaSlicer/OrcaSlicer/issues/7210#issuecomment-4054018656
# # Override DRI_PRIME to prevent OrcaSlicer from selecting a non-existent GPU
# export DRI_PRIME=0
# # Disable WebKit compositing (crashes under XWayland on some hardware)
# export WEBKIT_DISABLE_COMPOSITING_MODE=1
# # Disable WebKit DMA-BUF renderer (crashes on some NVIDIA setups)
# export WEBKIT_DISABLE_DMABUF_RENDERER=1
	${INSTALL_PROGRAM} ${CARGO_TARGET_DIR}/*/tchap-desktop ${STAGEDIR}${LOCALBASE}/bin

.include <bsd.port.mk>
