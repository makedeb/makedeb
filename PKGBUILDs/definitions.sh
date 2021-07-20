# Stable
stable_debian_depends=('bash' 'binutils' 'file' 'dpkg-dev' 'makepkg')
stable_arch_depends=('dpkg')

stable_debian_optdepends=('apt')

stable_debian_conflicts=('makedeb-beta' 'makedeb-alpha')
stable_arch_conflicts=('makedeb-beta' 'makedeb-alpha')

# Beta
beta_debian_depends=('bash' 'binutils' 'file' 'dpkg-dev' 'makepkg')
beta_arch_depends=('dpkg')

beta_debian_optdepends=('apt')

beta_debian_conflicts=('makedeb' 'makedeb-alpha')
beta_arch_conflicts=('makedeb' 'makedeb-alpha')

# Alpha
alpha_debian_depends=('bash' 'binutils' 'file' 'dpkg-dev' 'makepkg')
alpha_arch_depends=('dpkg')

alpha_debian_optdepends=('apt')

alpha_debian_conflicts=('makedeb' 'makedeb-beta')
alpha_arch_conflicts=('makedeb' 'makedeb_alpha')
