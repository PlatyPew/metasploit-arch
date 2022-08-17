FROM lopsided/archlinux:devel as build

RUN sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 8/g' /etc/pacman.conf && \
    pacman -Sy --noconfirm && \
    sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers && \
    curl -fsSL https://blackarch.org/strap.sh | sh && \
    pacman -S yay --noconfirm && \
    groupadd users && groupadd wheel && \
    useradd -m -g users -G wheel -s /bin/bash builder

USER builder
WORKDIR /home/builder
COPY PKGBUILD .

RUN sudo pacman -S --noconfirm ruby ruby-bundler libpcap postgresql-libs libxslt inetutils && \
    MAKEFLAGS="-j $(nproc)" makepkg && \
    mkdir package && \
    mv metasploit-*.pkg.tar.xz package

FROM scratch
COPY --from=build /home/builder/package/ .
