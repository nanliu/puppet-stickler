class stickler::package {
  # development package for passenger
  ensure_packages(['make', 'gcc', 'gcc-c++', 'openssl-devel'])

  package { 'stickler':
    ensure   => $version,
    provider => 'gem',
  }
}
