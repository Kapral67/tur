# shellcheck shell=bash
# shellcheck disable=SC2034
TERMUX_PKG_HOMEPAGE="https://aws.amazon.com/cli"
TERMUX_PKG_DESCRIPTION="A Unified Tool to Manage Your AWS Services"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_RECOMMENDS="man"
TERMUX_PKG_VERSION="2.15.23"
TERMUX_PKG_SRCURL="https://awscli.amazonaws.com/awscli-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="SKIP_CHECKSUM"
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="man"
TERMUX_PKG_BUILD_DEPENDS="ldd, python-pip"
TERMUX_PKG_PYTHON_COMMON_DEPS="setuptools-rust, wheel"

_import_awscli_pgp_key() {
	# This key expired 2023-09-17 but it is still in use
	# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-source-install.html#source-getting-started-install-reqs
	cat <<-EOF | gpg --import -
		-----BEGIN PGP PUBLIC KEY BLOCK-----

		mQINBF2Cr7UBEADJZHcgusOJl7ENSyumXh85z0TRV0xJorM2B/JL0kHOyigQluUG
		ZMLhENaG0bYatdrKP+3H91lvK050pXwnO/R7fB/FSTouki4ciIx5OuLlnJZIxSzx
		PqGl0mkxImLNbGWoi6Lto0LYxqHN2iQtzlwTVmq9733zd3XfcXrZ3+LblHAgEt5G
		TfNxEKJ8soPLyWmwDH6HWCnjZ/aIQRBTIQ05uVeEoYxSh6wOai7ss/KveoSNBbYz
		gbdzoqI2Y8cgH2nbfgp3DSasaLZEdCSsIsK1u05CinE7k2qZ7KgKAUIcT/cR/grk
		C6VwsnDU0OUCideXcQ8WeHutqvgZH1JgKDbznoIzeQHJD238GEu+eKhRHcz8/jeG
		94zkcgJOz3KbZGYMiTh277Fvj9zzvZsbMBCedV1BTg3TqgvdX4bdkhf5cH+7NtWO
		lrFj6UwAsGukBTAOxC0l/dnSmZhJ7Z1KmEWilro/gOrjtOxqRQutlIqG22TaqoPG
		fYVN+en3Zwbt97kcgZDwqbuykNt64oZWc4XKCa3mprEGC3IbJTBFqglXmZ7l9ywG
		EEUJYOlb2XrSuPWml39beWdKM8kzr1OjnlOm6+lpTRCBfo0wa9F8YZRhHPAkwKkX
		XDeOGpWRj4ohOx0d2GWkyV5xyN14p2tQOCdOODmz80yUTgRpPVQUtOEhXQARAQAB
		tCFBV1MgQ0xJIFRlYW0gPGF3cy1jbGlAYW1hem9uLmNvbT6JAlQEEwEIAD4WIQT7
		Xbd/1cEYuAURraimMQrMRnJHXAUCXYKvtQIbAwUJB4TOAAULCQgHAgYVCgkICwIE
		FgIDAQIeAQIXgAAKCRCmMQrMRnJHXJIXEAChLUIkg80uPUkGjE3jejvQSA1aWuAM
		yzy6fdpdlRUz6M6nmsUhOExjVIvibEJpzK5mhuSZ4lb0vJ2ZUPgCv4zs2nBd7BGJ
		MxKiWgBReGvTdqZ0SzyYH4PYCJSE732x/Fw9hfnh1dMTXNcrQXzwOmmFNNegG0Ox
		au+VnpcR5Kz3smiTrIwZbRudo1ijhCYPQ7t5CMp9kjC6bObvy1hSIg2xNbMAN/Do
		ikebAl36uA6Y/Uczjj3GxZW4ZWeFirMidKbtqvUz2y0UFszobjiBSqZZHCreC34B
		hw9bFNpuWC/0SrXgohdsc6vK50pDGdV5kM2qo9tMQ/izsAwTh/d/GzZv8H4lV9eO
		tEis+EpR497PaxKKh9tJf0N6Q1YLRHof5xePZtOIlS3gfvsH5hXA3HJ9yIxb8T0H
		QYmVr3aIUes20i6meI3fuV36VFupwfrTKaL7VXnsrK2fq5cRvyJLNzXucg0WAjPF
		RrAGLzY7nP1xeg1a0aeP+pdsqjqlPJom8OCWc1+6DWbg0jsC74WoesAqgBItODMB
		rsal1y/q+bPzpsnWjzHV8+1/EtZmSc8ZUGSJOPkfC7hObnfkl18h+1QtKTjZme4d
		H17gsBJr+opwJw/Zio2LMjQBOqlm3K1A4zFTh7wBC7He6KPQea1p2XAMgtvATtNe
		YLZATHZKTJyiqA==
		=vYOk
		-----END PGP PUBLIC KEY BLOCK-----
	EOF
}

_get_awscli_src_tarball() {
	local tarball
	local sig

	_import_awscli_pgp_key

	tarball="$(mktemp -p "$TERMUX_PKG_TMPDIR" "awscli.XXXXXX.tar.gz")"
	sig="$(mktemp -p "$TERMUX_PKG_TMPDIR" "awscli.XXXXXX.sig")"

	# Add static DNS entries for awscli.amazonaws.com if not already present
	# curl -s awscli.amazonaws.com >/dev/null 2>&1
	# if [ $? -eq 6 ]; then
	# 	echo "awscli.amazonaws.com" >>/system/etc/static-dns-hosts.txt
	# 	update-static-dns >/dev/null 2>&1
	# fi

	if [[ "${*}" =~ "--latest" ]]; then
		curl -Lo "${tarball}" https://awscli.amazonaws.com/awscli.tar.gz
		curl -Lo "${sig}" https://awscli.amazonaws.com/awscli.tar.gz.sig
	else
		curl -Lo "${tarball}" "${TERMUX_PKG_SRCURL}"
		curl -Lo "${sig}" "${TERMUX_PKG_SRCURL}.sig"
	fi

	if ! gpg --verify "${sig}" "${tarball}"; then
		rm -f "${sig}"
		rm -f "${tarball}"
		termux_error_exit "Error: failed to validate upstream source code"
	fi

	rm -f "${sig}"

	echo "${tarball}"
}

termux_pkg_auto_update() {
	local tarball
	local version

	tarball="$(_get_awscli_src_tarball --latest)"
	version="$(tar tzf "${tarball}" | head -n 1 | grep -oP "\d+\.\d+\.\d+")"
	rm -f "${tarball}"

	if [ -z "${version}" ]; then
		termux_error_exit "Error: failed to extract latest version"
	fi

	if [ "${TERMUX_PKG_VERSION}" != "${version}" ]; then
		termux_pkg_upgrade_version "${version}" --skip-version-check
	fi
}

termux_step_get_source() {
	local tarball
	tarball="$(_get_awscli_src_tarball)"
	mkdir -p "${TERMUX_PKG_SRCDIR}"
	tar --strip-components=1 -xf "${tarball}" -C "${TERMUX_PKG_SRCDIR}"
	rm -f "${tarball}"
	# Unneeded dependency since we have python>=3.10
	sed -i '/ruamel.yaml.clib/d' "${TERMUX_PKG_SRCDIR}/pyproject.toml"
	# TODO: Confirm this is still needed
	# sed -i 's/self._utils.create_venv(self._venv_dir, with_pip=True)/self._utils.create_venv(self._venv_dir, with_pip=False)/g' "${TERMUX_PKG_SRCDIR}/backends/build_system/awscli_venv.py"
}

_build_awscrt() {
	local toolchain_file
	local sys_proc

	termux_setup_cmake

	toolchain_file="$(mktemp -p "${TERMUX_PKG_TMPDIR}" "aws-crt-python.XXXXXX.cmake")"
	cat <<-EOF >"${toolchain_file}"
		set(CMAKE_LINKER "$(command -v ${LD}) ${LDFLAGS}")
		set(CMAKE_BUILD_TYPE "${build_type}")
		set(CMAKE_C_FLAGS "${CFLAGS} ${CPPFLAGS}")
		set(CMAKE_CXX_FLAGS "${CXXFLAGS} ${CPPFLAGS}")
		set(CMAKE_FIND_ROOT_PATH "${TERMUX_PREFIX}")
		set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
		set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER)
		set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER)
		set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE NEVER)
		set(CMAKE_PREFIX_PATH "${TERMUX_PREFIX}")
		set(CMAKE_USE_SYSTEM_LIBRARIES ON)
	EOF

	# FIXME: CMAKE_TOOLCHAIN_FILE="${toolchain_file}" AWS_CRT_BUILD_USE_SYSTEM_LIBCRYPTO=1 \
	pip3 install --no-binary :all: "awscrt==${*}"

	rm -f "${toolchain_file}"
}

_build_cryptography() {
	termux_setup_rust

	PYO3_CROSS_LIB_DIR="${TERMUX_PREFIX}/lib" CARGO_BUILD_TARGET="${CARGO_TARGET_NAME}" \
		pip3 install "cryptography==${*}"
}

termux_step_pre_configure() {
	if ! ${TERMUX_ON_DEVICE_BUILD}; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	local requirements
	local awscrt_version
	local cryptography_version

	pip3 install pip-tools

	requirements="$(mktemp -p "${TERMUX_PKG_SRCDIR}" "awscli-requirements.XXXXXX.txt")"
	pip-compile --strip-extras --allow-unsafe --no-annotate -qo "${requirements}" \
		requirements/download-deps/bootstrap.txt requirements/portable-exe-extras.txt pyproject.toml

	awscrt_version="$(grep -oP 'awscrt==\K\d+[.\d+]*' "${requirements}")"
	sed -i '/awscrt/d' "${requirements}"

	cryptography_version="$(grep -oP 'cryptography==\K\d+[.\d+]*' "${requirements}")"
	sed -i '/cryptography/d' "${requirements}"

	pip3 install -r "${requirements}"

	_build_awscrt "${awscrt_version}"
	_build_cryptography "${cryptography_version}"
}

termux_step_configure() {
	# cannot use `--with-download-deps` here because it creates a venv but we want to use
	# crossenv provided by `termux_setup_python_pip` via `TERMUX_PKG_SETUP_PYTHON=true`
	./configure --prefix="${TERMUX_PREFIX}" --with-install-type=portable-exe
}

termux_step_make() {
	python3 -c "import site; print('\n'.join(site.getsitepackages()))" | xargs -n 1 mkdir -p
	make
}

termux_step_make_install() {
	make install
}
