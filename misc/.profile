# To find pip and luarocks packages
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Java
JAVA_HOME="/opt/jdk-19.0.1"
export PATH=$JAVA_HOME/bin:$PATH

# Maven
M2_HOME="/opt/apache-maven-3.8.6"
export PATH=$M2_HOME/bin:$PATH
