#!/bin/bash

####################################################################################
# Shell script para gerar configuração de melhoria na performance do PostgreSQL 15.#
# Documento oficiais foram utilizados:                                             #
# https://www.postgresql.org/docs/current/runtime-config-resource.html             #
# https://www.postgresql.org/docs/15/runtime-config-wal.html#GUC-FULL-PAGE-WRITES  #
# Por Caio Henrique Novelletto                                                     #
####################################################################################

#------------------------------------------------------------------------------------------------
# max_connections - Definido pelo user;

#------------------------------------------------------------------------------------------------
## shared_buffers - 25% da memória informada;
SHARED_BUFFERS=$("Define a quantidade de memória(Valor inteiro) que o servidor de banco de dados usa para buffers de memória compartilhada. 
Se o servidor de banco de dados tiver com 1 GB ou mais de RAM, um valor inicial razoável de shared_buffersé 25% da memória do seu SO. 
Existem alguns processos em que configurações ainda maiores de shared_bufferssão são eficazes, mas como o PostgreSQL também depende do cache do sistema operacional, 
é improvável que uma alocação de mais de 40% de RAM funcione melhor do que uma quantidade menor. \n")

#------------------------------------------------------------------------------------------------
# effective_cache_size - 75 da memória informada;
EFFECTIVE_CACHE_SIZE=$("Define o tamanho do cache em disco disponível para uma única consulta. 
Isto é levado em consideração nas estimativas do custo de utilização de um índice; um valor mais alto aumenta a probabilidade de uso de varreduras de índice; 
um valor mais baixo aumenta a probabilidade de uso de varreduras sequenciais. Ao definir este parâmetro você deve considerar os buffers compartilhados do PostgreSQL e a 
parte do cache de disco do kernel que será usada para arquivos de dados do PostgreSQL , embora alguns dados possam existir em ambos os locais. \n")

#------------------------------------------------------------------------------------------------
# work_mem - total de conexão  /  pelo total de memória ram;
WORK_MEM=$("Define a quantidade(valor inteiro) máxima de memória a ser usada por uma operação de consulta antes de gravar em arquivos temporários do disco. 
Se esse valor não for especificado, ele será considerado como quilobytes, onde seu valor padrão é de 4MB. 
Observe que, para uma consulta complexa, diversas operações podem estar sendo executadas em paralelo e geralmente, cada operação terá permissão 
para usar tanto a memória quanto esse valor especifica antes de começar a gravar dados em arquivos temporários. \n")

#------------------------------------------------------------------------------------------------
# maintenance_work_mem - 11% do total de memória ram;
MAINTENANCE_WORK_MEM=$("Especifica a quantidade(valor inteiro) máxima de memória a ser usada pelas operações de manutenção, como VACUUM, CREATE INDEXe ALTER TABLE ADD FOREIGN KEY. 
Se esse valor não for especificado, ele será considerado como quilobytes. O padrão é 64 megabytes ( 64MB). 
É prudente definir esse valor significativamente maior que work_mem. Configurações maiores podem melhorar o desempenho da limpeza e da restauração de dumps do banco de dados. \n")

#------------------------------------------------------------------------------------------------
# huge_pages = off
HUGE_PAGES=$("Controla as páginas grandes que são solicitadas da memória compartilhada. Os valores válidos são try(o padrão), on, e off. 
Com huge_pages definido como try, o servidor tentará solicitar páginas enormes, mas voltará ao padrão se falhar. 
Com on, a falha na solicitação de páginas grandes impedirá a inicialização do servidor. 
Com off, páginas enormes não serão solicitadas. \n")

#------------------------------------------------------------------------------------------------
# max_worker_processes = total de cpu informado;
MAX_WORKER_PROCESSES=$("Define o número máximo(valor inteiro) de processos em segundo plano que o sistema pode suportar. 
Caso estiver utilizando replicação de dados, você deve configurar esse parâmetro com um valor igual ou superior ao do servidor primário. 
Caso contrário, consultas não serão permitidas no servidor standby. \n")

#------------------------------------------------------------------------------------------------
# max_parallel_workers_per_gather = total de cpu informado / 2;
MAX_PARALLEL_WORKERS_PER_GATHER=$("Define o número máximo de processos que podem ser iniciados por um único Gather. 
Processos paralelos são retirados do conjunto de processos estabelecido por max_worker_processes, pois é limitado pelo max_parallel_workers . 
O número de processos pode não estar disponível em tempo de execução. Se isto ocorrer, o serviço funcionará com menos processos do que o esperado, 
o que pode ser ineficiente. O valor padrão é 2. \n")

#------------------------------------------------------------------------------------------------
# max_parallel_workers = total de cpu informado;
MAX_PARALLEL_WORKERS=$("Define o número(valor inteiro) máximo de processos que o sistema pode suportar para operações paralelas. O valor padrão é 8. 
Ao aumentar ou diminuir esse valor, você também precisa ajustar max_parallel_maintenance_workers e max_parallel_workers_per_gather . Além disso, uma configuração 
para esse valor superior a max_worker_processes não terá efeito, uma vez que os processos paralelos são retirados do conjunto de processos de trabalho estabelecidos por ele. \n")

#------------------------------------------------------------------------------------------------
# max_parallel_maintenance_workers =  total de cpu informado / 2;
MAX_PARALLEL_MAINTENANCE_WORKERS=$("Define o número máximo de processos paralelos que podem ser iniciados por um único comando do utilitário. Atualmente, 
os comandos do utilitário paralelo que suportam o uso de processos paralelos são CREATE e INDEX.
O valor padrão é 2. Definir esse valor como 0 desativa o uso de trabalhadores paralelos por comandos utilitários. \n")

#------------------------------------------------------------------------------------------------
# checkpoint_completion_target -0.9 Default
CHECKPOINT_COMPLETION_TARGET=$("Para evitar consumo excessivo do sistema com uma explosão de gravações de páginas, a gravação de buffers durante um ponto de verificação 
é distribuída por um período de tempo. Esse período é controlado por checkpoint_completion_target , que é fornecido como uma fração do intervalo do ponto de 
verificação (configurado usando checkpoint_timeout). Com o valor padrão de 0,9. \n")

#------------------------------------------------------------------------------------------------
# wal_buffers - 16mb Default
WAL_BUFFERS=$("A quantidade de memória compartilhada usada para WAL que ainda não foram gravados no disco. A configuração padrão -1 seleciona um tamanho de 3% de shared_buffers, 
mas não menos que 64kB nem mais que o tamanho de um segmento WAL, normalmente 16MB. Portanto essa configuração não pode estar vazia. \n")
#------------------------------------------------------------------------------------------------
# min_wal_size = 1GB Default
MIN_WAL_SIZE=$("Contanto que o uso do disco WAL permaneça abaixo dessa configuração, os arquivos WAL antigos serão sempre reciclados para uso futuro em um ponto de verificação, 
em vez de removidos. Isso pode ser usado para garantir que espaço suficiente do WAL seja reservado para lidar com picos no uso do WAL, por exemplo, 
ao executar grandes trabalhos em lote. Se esse valor for especificado sem unidades, ele será considerado megabytes. O padrão é 80 MB. \n")

#------------------------------------------------------------------------------------------------
# max_wal_size = 4GB Default
MAX_WAL_SIZE=$("Tamanho máximo para permitir que o WAL cresça durante checkpoints automáticos. O tamanho do WAL pode exceder max_wal_size em circunstâncias especiais,
como carga pesada, causando falha no archive_command. \n")

#------------------------------------------------------------------------------------------------
# default_statistics_target = 100 Default
DEFAULT_STATISTICS_TARGET=$("É um parâmetro de configuração que determina o destino de estatísticas padrão para colunas da tabela que não possuem um destino explícito. \n")

#------------------------------------------------------------------------------------------------
# random_page_cost = 4 Default
RANDOM_PAGE_COST=$("Define a estimativa de processo do custo de uma página de disco que é consultada de forma não sequencial. O padrão é 4.0. 
Esse valor pode ser substituído para tabelas e índices em um tablespace específico definindo o parâmetro de tablespace de mesmo nome (consulte ALTER TABLESPACE ). \n")

#------------------------------------------------------------------------------------------------
# Entradas digitadas pelo usuário para fazer os calculos:
read -p "Digite o número máximo de conexões (max_connections): " max_connections
read -p "Digite a quantidade de memória RAM disponível em GB: " ram_gb
read -p "Digite o número total de CPUs disponíveis: " total_cpus
sleep 1

#------------------------------------------------------------------------------------------------
# Loading
echo -n "Gerando configurações "
for i in {1..10}; do
  echo -n "."
  sleep 0.03 
done

#------------------------------------------------------------------------------------------------
# Cálculos com base no que o usuário digitou:
shared_buffers=$((ram_gb / 4))GB
effective_cache_size=$((ram_gb * 3 / 4))GB
work_mem=$((ram_gb * 1024 / max_connections))MB
maintenance_work_mem=$((ram_gb * 11 / 100))GB
max_worker_processes=$total_cpus
max_parallel_workers_per_gather=$((total_cpus / 2))
max_parallel_workers=$total_cpus
max_parallel_maintenance_workers=$((total_cpus / 2))
checkpoint_completion_target=0.9
wal_buffers=16MB
min_wal_size=1GB
max_wal_size=4GB
default_statistics_target=100
huge_pages=off
random_page_cost=4

#------------------------------------------------------------------------------------------------
# Print resultado:
echo -e "\e[1;33m[Configurações calculadas: ]"
echo -e "\e[1;33m[max_connections = ] \e[1;36m$max_connections"
echo -e "\e[1;33m[shared_buffers = \e[1;36m$shared_buffers"
echo -e "\e[1;33m[effective_cache_size = ] \e[1;36m$effective_cache_size"
echo -e "\e[1;33m[work_mem = ] \e[1;36m$work_mem"
echo -e "\e[1;33m[maintenance_work_mem = ] \e[1;36m$maintenance_work_mem"
echo -e "\e[1;33m[checkpoint_completion_target = ] \e[1;36m$checkpoint_completion_target"
echo -e "\e[1;33m[wal_buffers = ] \e[1;36m$wal_buffers"
echo -e "\e[1;33m[min_wal_size = ] \e[1;36m$min_wal_size"
echo -e "\e[1;33m[max_wal_size = ] \e[1;36m$max_wal_size"
echo -e "\e[1;33m[default_statistics_target = ] \e[1;36m$default_statistics_target"
echo -e "\e[1;33m[huge_pages = ] \e[1;36m$huge_pages"
echo -e "\e[1;33m[random_page_cost = ] \e[1;36m$random_page_cost"
echo -e "\e[1;33m[max_worker_processes = ] \e[1;36m$max_worker_processes"
echo -e "\e[1;33m[max_parallel_workers_per_gather = ] \e[1;36m$max_parallel_workers_per_gather"
echo -e "\e[1;33m[max_parallel_workers = ] \e[1;36m$max_parallel_workers"
echo -e "\e[1;33m[max_parallel_maintenance_workers = ] \e[1;36m$max_parallel_maintenance_workers \n"
echo -e "#--> Done ✔️ \n"
sleep 2

#------------------------------------------------------------------------------------------------
# Questionamento para exibir o significado das variaveis:
read -p "👀 Você deseja saber mais sobre essas configurações❔ (s)im ou (n)ão: " sobre_config

if [ "$sobre_config" = "s" ] || [ "$sobre_config" = "S" ]; then
    echo "O significado das variáveis configuradas são: \n"
    echo "shared_buffers: \n" $SHARED_BUFFERS
    echo "effective_cache_size: \n" $EFFECTIVE_CACHE_SIZE
    echo "work_mem: \n" $WORK_MEM
    echo "maintenance_work_mem: \n" $MAINTENANCE_WORK_MEM
    echo "HUGE_PAGES: \n" $HUGE_PAGES
    echo "MAX_WORKER_PROCESSES \n" $MAX_WORKER_PROCESSES
    echo "max_parallel_workres_per_gather: \n" $MAX_PARALLEL_WORKERS_PER_GATHER
    echo "max_parallel_workers: \n" $MAX_PARALLEL_WORKERS
    echo "max_parallel_maintenance_workers: \n" $MAX_PARALLEL_MAINTENANCE_WORKERS
    echo "checkpoint_completion_target: \n" $CHECKPOINT_COMPLETION_TARGET
    echo "wal_buffers: \n" $WAL_BUFFERS
    echo "min_wal_size: \n" $MIN_WAL_SIZE
    echo "max_wal_size: \n" $MAX_WAL_SIZE
    echo "default_statistics_target: \n" $DEFAULT_STATISTICS_TARGET
    echo "random_page_cost: \n" $RANDOM_PAGE_COST
else 
    echo "Ok, até uma próxima! 😊"
fi
