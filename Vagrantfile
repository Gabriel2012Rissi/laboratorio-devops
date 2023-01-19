# Versão da sintaxe do Vagrantfile
VAGRANTFILE_API_VERSION = "2"

# Nome do Projeto
PROJECT_NAME = "Laboratório DevOps"

# Função para substituir os acentos e caracteres especiais
# Código baseado no 'gist' de: https://gist.github.com/lfzawacki/6223816
def remove_accents(string)
  accents = {
    ['á','à','â','ä','ã'] => 'a',
    ['é','è','ê','ë'] => 'e',
    ['í','ì','î','ï'] => 'i',
    ['ó','ò','ô','ö','õ'] => 'o',
    ['ú','ù','û','ü'] => 'u',
    ['ç'] => 'c',
    ['ñ'] => 'n'
  }
  accents.each do |accent, replacement|
    accent.each do |letter|
      string = string.gsub(letter, replacement)
    end
  end
  string
end

# Função para padronizar o nome das VMs
def vagrant_name(name)
  name = name.split(" ").map { |word| remove_accents(word.downcase) }.join("-") + "-vm"
  name
end

Vagrant.configure("2") do |config|
  # Vagrant box
  config.vm.box = "debian/bullseye64"
  #
  # Configurando a VM
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.name = vagrant_name(PROJECT_NAME)
  end
  #
  # Script de provisionamento
  config.vm.provision "shell", path: "provisioner.sh"
  #
  # Configurando o 'workdir' do Vagrant
  config.ssh.extra_args = ["-t", "cd /vagrant; bash --login"]
  #
  # Portas do Vagrant
  # ================================
  #
  # Gitea
  config.vm.network "forwarded_port", guest: 8180, host: 8180
  config.vm.network "forwarded_port", guest: 8122, host: 8122
  #
  # Jenkins
  config.vm.network "forwarded_port", guest: 8280, host: 8280
  config.vm.network "forwarded_port", guest: 8250, host: 8250
  #
  # SonarQube
  config.vm.network "forwarded_port", guest: 8380, host: 8380
end