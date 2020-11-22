# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MULTILIB_COMPAT=( abi_x86_{32,64} )

inherit unpacker multilib-minimal

SUPER_PN='amdgpu-pro'
MY_PV=$(ver_rs 2 '-')

DESCRIPTION="Proprietary OpenCL implementation for AMD GPUs"
HOMEPAGE="https://www.amd.com/en/support/kb/release-notes/rn-amdgpu-unified-navi-linux"
SRC_URI="${SUPER_PN}-${MY_PV}-ubuntu-20.04.tar.xz"

LICENSE="AMD-GPU-PRO-EULA"
SLOT="0"
KEYWORDS="amd64"

RESTRICT="bindist mirror fetch strip"

BDEPEND="dev-util/patchelf"
COMMON=">=virtual/opencl-3"
DEPEND="${COMMON}"
RDEPEND="${COMMON} dev-libs/libedit x11-libs/libdrm[video_cards_amdgpu,video_cards_radeon]"

QA_PREBUILT="/opt/amdgpu/lib*/*"

S="${WORKDIR}/${SUPER_PN}-${MY_PV}-ubuntu-20.04"

pkg_nofetch() {
	local pkgver=$(ver_cut 1-2)
	einfo "Please download Radeon Software for Linux version ${pkgver} for Ubuntu 20.04 from"
	einfo "    ${HOMEPAGE}"
	einfo "The archive should then be placed into your distfiles directory."
}

src_unpack() {
	default

	local ids_ver="1.0.0"
	local patchlevel=$(ver_cut 3)
	cd "${S}" || die
	#unpack_deb "${S}/libdrm-amdgpu-common_${ids_ver}-${patchlevel}_all.deb"
	multilib_parallel_foreach_abi multilib_src_unpack
}

multilib_src_unpack() {
	local libdrm_ver="2.4.100"
	local patchlevel=$(ver_cut 3)
	local deb_abi
	[[ ${ABI} == x86 ]] && deb_abi=i386

	mkdir -p "${BUILD_DIR}" || die
	pushd "${BUILD_DIR}" >/dev/null || die
	unpack_deb "${S}/amdgpu-core_${MY_PV}_all.deb"
	unpack_deb "${S}/amdgpu-lib_${MY_PV}_amd64.deb"
	unpack_deb "${S}/amdgpu-pro-core_${MY_PV}_all.deb"
	unpack_deb "${S}/amdgpu-pro-rocr-opencl_${MY_PV}_amd64.deb"
	unpack_deb "${S}/amdgpu-pro_${MY_PV}_amd64.deb"
	unpack_deb "${S}/amdgpu_${MY_PV}_amd64.deb"
	unpack_deb "${S}/opencl-orca-amdgpu-pro-icd_${MY_PV}_${deb_abi:-${ABI}}.deb"
	unpack_deb "${S}/opencl-rocr-amdgpu-pro_${MY_PV}_${deb_abi:-${ABI}}.deb"
	unpack_deb "${S}/rocm-device-libs-amdgpu-pro_1.0.0-${patchlevel}_${deb_abi:-${ABI}}.deb"
	unpack_deb "${S}/hip-rocr-amdgpu-pro_${MY_PV}_amd64.deb"
	unpack_deb "${S}/hsa-runtime-rocr-amdgpu_1.2.0-${patchlevel}_amd64.deb"
	unpack_deb "${S}/hsakmt-roct-amdgpu_1.0.9-${patchlevel}_amd64.deb"
	unpack_deb "${S}/ocl-icd-libopencl1-amdgpu-pro_${MY_PV}_amd64.deb"
	unpack_deb "${S}/libllvm-amdgpu-pro-rocm_11.0-${patchlevel}_amd64.deb"
	unpack_deb "${S}/libllvm10.0-amdgpu_10.0-${patchlevel}_amd64.deb"
	unpack_deb "${S}/llvm-amdgpu-10.0-runtime_10.0-${patchlevel}_amd64.deb"
	unpack_deb "${S}/llvm-amdgpu-10.0_10.0-${patchlevel}_amd64.deb"
	unpack_deb "${S}/llvm-amdgpu-pro-rocm-dev_11.0-${patchlevel}_amd64.deb"
	unpack_deb "${S}/llvm-amdgpu-runtime_10.0-${patchlevel}_amd64.deb"
	unpack_deb "${S}/llvm-amdgpu_10.0-${patchlevel}_amd64.deb"
	unpack_deb "${S}/comgr-amdgpu-pro_1.7.0-${patchlevel}_${deb_abi:-${ABI}}.deb"
	#unpack_deb "${S}/libdrm-amdgpu-amdgpu1_${libdrm_ver}-${patchlevel}_${deb_abi:-${ABI}}.deb"
	#unpack_deb "${S}/libdrm-amdgpu-radeon1_${libdrm_ver}-${patchlevel}_${deb_abi:-${ABI}}.deb"
	#unpack_deb "${S}/libdrm-amdgpu-common_1.0.0-${patchlevel}_all.deb"
	#unpack_deb "${S}/libdrm-amdgpu-utils_${libdrm_ver}-${patchlevel}_${deb_abi:-${ABI}}.deb"
	#unpack_deb "${S}/libdrm2-amdgpu_${libdrm_ver}-${patchlevel}_amd64.deb"
	#unpack_deb "${S}/clinfo-amdgpu-pro_${MY_PV}_amd64.deb"
	unpack_deb "${S}/libgl1-amdgpu-pro-appprofiles_${MY_PV}_all.deb"
	popd >/dev/null || die
}

multilib_src_install() {
	local dir_abi short_abi
	[[ ${ABI} == x86 ]] && dir_abi=i386-linux-gnu && short_abi=32
	[[ ${ABI} == amd64 ]] && dir_abi=x86_64-linux-gnu && short_abi=64

	into "/opt/amdgpu"
	patchelf --set-rpath '$ORIGIN' "opt/${SUPER_PN}/lib/${dir_abi}"/libamdocl-orca${short_abi}.so || die "Failed to fix library rpath"
	patchelf --set-rpath '$ORIGIN' "opt/${SUPER_PN}/lib/${dir_abi}"/libamdocl${short_abi}.so || die "Failed to fix library rpath"
	dolib.so "opt/${SUPER_PN}/lib/${dir_abi}"/lib*.so "opt/${SUPER_PN}/lib/${dir_abi}"/lib*.so.*
	dolib.so "opt/amdgpu/lib/${dir_abi}"/llvm-*/lib/lib*.so "opt/amdgpu/lib/${dir_abi}"/llvm-*/lib/lib*.so.*
	rm -f "opt/amdgpu/lib/${dir_abi}"/libLLVM-*.so "opt/amdgpu/lib/${dir_abi}"/libLTO.so.* "opt/amdgpu/lib/${dir_abi}"/libRemarks.so.*
	dolib.so "opt/amdgpu/lib/${dir_abi}"/lib*.so.*
	ln -sf libedit.so.0 /$(get_libdir)/libedit.so.2 || die "Cannot create symlink for libedit"

	insinto /etc/OpenCL/vendors
	echo "/opt/amdgpu/$(get_libdir)/libamdocl-orca${short_abi}.so" \
		> "${T}/${SUPER_PN}-orca-${ABI}.icd" || die "Failed to generate ICD file for ABI ${ABI}"
	echo "/opt/amdgpu/$(get_libdir)/libamdocl${short_abi}.so" \
		> "${T}/${SUPER_PN}-pal-${ABI}.icd" || die "Failed to generate ICD file for ABI ${ABI}"
	doins "${T}/${SUPER_PN}-orca-${ABI}.icd"
	doins "${T}/${SUPER_PN}-pal-${ABI}.icd"

	insinto "/etc/amd"
	doins etc/amd/amdapfxx.blb
}

multilib_src_install_all() {
	insinto "/opt/amdgpu"
	#doins -r opt/amdgpu/share
}

pkg_postinst() {
	if [[ -z "${REPLACING_VERSIONS}" ]]; then
		ewarn "Please note that using proprietary OpenCL libraries together with the"
		ewarn "Open Source amdgpu stack is not officially supported by AMD. Do not ask them"
		ewarn "for support in case of problems with this package."
		ewarn ""
		ewarn "Furthermore, if you have the whole AMDGPU-Pro stack installed this package"
		ewarn "will almost certainly conflict with it. This might change once AMDGPU-Pro"
		ewarn "has become officially supported by Gentoo."
	fi

	elog ""
	elog "This package is now DEPRECATED on amd64 in favour of dev-libs/rocm-opencl-runtime."
	elog "Moreover, it only provides legacy AMDGPU-Pro OpenCL libraries which are not compatible with Vega 10 and newer GPUs."
	elog ""
}
