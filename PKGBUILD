# Maintainer: Levente Polyak <anthraxx[at]archlinux[dot]org>
# Maintainer: kpcyrd <kpcyrd[at]archlinux[dot]org>
# Contributor: Sabart Otto - Seberm <seberm[at]seberm[dot]com>
# Contributor: Tobias Veit - nIcE <m.on.key.tobi[at]gmail[dot]com>

pkgname=metasploit
pkgver=6.2.11
pkgrel=1
pkgdesc='Advanced open-source platform for developing, testing, and using exploit code'
url='https://www.metasploit.com/'
arch=('aarch64' 'x86_64')
license=('BSD')
depends=('ruby' 'ruby-bundler' 'libpcap' 'postgresql-libs' 'sqlite' 'libxslt' 'libxml2' 'inetutils' 'git')
options=('!strip' '!emptydirs')
source=(https://github.com/rapid7/metasploit-framework/archive/${pkgver}/${pkgname}-${pkgver}.tar.gz)
sha512sums=('b0ccb892dd74353218757b0700fa5a235427bf6fd3218374da35b9a469af1f22f6eb5875750e5d42fd0b115228374e6113cf6d8d1bee4a2c7f3ca5b893552a8c')
b2sums=('7fc2dd522fa0e3a8e3e358fa5bb3c3a231dfc62cfcaa6fbafa1476ccf4e9546b2b596b6daf1422f40cdf30b243007fae450c726f4e22ae9e5d30ac9a6c385d87')

prepare() {
  cd ${pkgname}-framework-${pkgver}

  # https://github.com/undler/bundler/issues/6882
  sed -e '/BUNDLED WITH/,+1d' -i Gemfile.lock

  bundle config build.nokogiri --use-system-libraries
  bundle config set --local deployment 'true'
  sed 's|git ls-files|find -type f|' -i metasploit-framework.gemspec
}

build() {
  cd ${pkgname}-framework-${pkgver}
  CFLAGS+=" -I/usr/include/libxml2"
  bundle install -j"$(nproc)" --no-cache
  find vendor/bundle/ruby -exec chmod o+r '{}' \;
  find vendor/bundle/ruby \( -name gem_make.out -or -name mkmf.log \) -delete
}

package() {
  cd ${pkgname}-framework-${pkgver}

  install -d "${pkgdir}/opt/${pkgname}" "${pkgdir}/usr/bin"
  cp -r . "${pkgdir}/opt/${pkgname}"

  for f in "${pkgdir}"/opt/${pkgname}/msf*; do
    local _msffile="${pkgdir}/usr/bin/`basename "${f}"`"
    echo -e "#!/bin/sh\nBUNDLE_GEMFILE=/opt/${pkgname}/Gemfile exec bundle exec ruby /opt/${pkgname}/`basename "${f}"` \"\$@\"" > "${_msffile}"
    chmod 755 "${_msffile}"
  done

  (cd "${pkgdir}/opt/${pkgname}"
    for f in tools/*/*.rb; do
      install -Dm 755 "${f}" ".${f}"
      echo -e "#!/bin/sh\nBUNDLE_GEMFILE=/opt/${pkgname}/Gemfile exec bundle exec ruby /opt/${pkgname}/."${f}" \"\$@\"" > "${f}"
      chmod 755 "${f}"
    done
  )

  install -Dm 644 external/zsh/_* -t "${pkgdir}/usr/share/zsh/site-functions"
  install -Dm 644 LICENSE COPYING -t "${pkgdir}/usr/share/licenses/${pkgname}"
  install -d "${pkgdir}/usr/share/doc"
  mv "${pkgdir}/opt/${pkgname}/documentation" "${pkgdir}/usr/share/doc/${pkgname}"
  rm "${pkgdir}/usr/bin/msfupdate"
  rm -r "${pkgdir}"/opt/metasploit/vendor/bundle/ruby/*/cache
  sed -e '/^BUNDLE_JOBS/d' -i "${pkgdir}/opt/metasploit/.bundle/config"
  find "${pkgdir}/opt/metasploit/vendor/bundle/ruby/" -name Makefile -delete
}

# vim: ts=2 sw=2 et: