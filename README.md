# PostgreSQL Optimizer

<div style="display: flex; justify-content: center;">
  <img alt="pgoptimizer" src="https://github.com/Kionovelletto/postgreSQL_Optimizer/blob/main/img/logo_pg_optimizer.png" width="300px">
</div>

O PostgreSQL Optimizer é uma ferramenta projetada para aprimorar o desempenho e a eficiência de seu banco de dados PostgreSQL que pode ser executado somente no linux. Desenvolvido especificamente para o PostgreSQL, um dos sistemas de gerenciamento de banco de dados de código aberto mais populares do mundo, o PostgreSQL Optimizer oferece uma série de recursos e funcionalidades destinados a otimizar o desempenho do seu banco de dados.

## Executando o script:
```shell
curl -o postgresql_optimizer.sh https://raw.githubusercontent.com/Kionovelletto/postgreSQL_Optimizer/main/postgresql_optimizer.sh
sudo chmod +x postgresql_optimizer.sh
./postgresql_optimizer.sh
```

## Recursos utilizados pela ferramenta:
### shared_buffers
Define a quantidade de memória(Valor inteiro) que o servidor de banco de dados usa para buffers de memória compartilhada. 
Se o servidor de banco de dados tiver com 1 GB ou mais de RAM, um valor inicial razoável de shared_buffersé 25% da memória do seu SO. 
Existem alguns processos em que configurações ainda maiores de shared_bufferssão são eficazes, mas como o PostgreSQL também depende do cache do sistema operacional, 
é improvável que uma alocação de mais de 40% de RAM funcione melhor do que uma quantidade menor.

### effective_cache_size
Define o tamanho do cache em disco disponível para uma única consulta. 
Isto é levado em consideração nas estimativas do custo de utilização de um índice; um valor mais alto aumenta a probabilidade de uso de varreduras de índice; 
um valor mais baixo aumenta a probabilidade de uso de varreduras sequenciais. Ao definir este parâmetro você deve considerar os buffers compartilhados do PostgreSQL e a 
parte do cache de disco do kernel que será usada para arquivos de dados do PostgreSQL , embora alguns dados possam existir em ambos os locais.

#### work_mem
Define a quantidade máxima de memória a ser usada por uma operação de consulta antes de gravar em arquivos temporários do disco. 
Se esse valor não for especificado, ele será considerado como quilobytes, onde seu valor padrão é de 4MB. 
Observe que, para uma consulta complexa, diversas operações podem estar sendo executadas em paralelo e geralmente, cada operação terá permissão 
para usar tanto a memória quanto esse valor especifica antes de começar a gravar dados em arquivos temporários.

### maintenance_work_mem
Especifica a quantidade(valor inteiro) máxima de memória a ser usada pelas operações de manutenção, como VACUUM, CREATE INDEXe ALTER TABLE ADD FOREIGN KEY. 
Se esse valor não for especificado, ele será considerado como quilobytes. O padrão é 64 megabytes ( 64MB). 
É prudente definir esse valor significativamente maior que work_mem. Configurações maiores podem melhorar o desempenho da limpeza e da restauração de dumps do banco de dados.

### huge_pages
Controla as páginas grandes que são solicitadas da memória compartilhada. Os valores válidos são try(o padrão), on, e off. 
Com huge_pages definido como try, o servidor tentará solicitar páginas enormes, mas voltará ao padrão se falhar. 
Com on, a falha na solicitação de páginas grandes impedirá a inicialização do servidor. 
Com off, páginas enormes não serão solicitadas.

### max_parallel_workers_per_gather
Define o número máximo de processos que podem ser iniciados por um único Gather. 
Processos paralelos são retirados do conjunto de processos estabelecido por max_worker_processes, pois é limitado pelo max_parallel_workers . 
O número de processos pode não estar disponível em tempo de execução. Se isto ocorrer, o serviço funcionará com menos processos do que o esperado, o que pode ser ineficiente. O valor padrão é 2.

### max_parallel_workers
Define o número(valor inteiro) máximo de processos que o sistema pode suportar para operações paralelas. O valor padrão é 8. 
Ao aumentar ou diminuir esse valor, você também precisa ajustar max_parallel_maintenance_workers e max_parallel_workers_per_gather . Além disso, uma configuração para esse valor superior a max_worker_processes não terá efeito, uma vez que os processos paralelos são retirados do conjunto de processos de trabalho estabelecidos por ele.

### max_parallel_maintenance_workers
Define o número máximo de processos paralelos que podem ser iniciados por um único comando do utilitário. Atualmente, 
os comandos do utilitário paralelo que suportam o uso de processos paralelos são CREATE e INDEX.
O valor padrão é 2. Definir esse valor como 0 desativa o uso de trabalhadores paralelos por comandos utilitários.

### checkpoint_completion_target
Para evitar consumo excessivo do sistema com uma explosão de gravações de páginas, a gravação de buffers durante um ponto de verificação é distribuída por um período de empo. Esse período é controlado por checkpoint_completion_target , que é fornecido como uma fração do intervalo do ponto de verificação (configurado usando checkpoint_timeout). Com o valor padrão de 0,9.

### wal_buffers
A quantidade de memória compartilhada usada para WAL que ainda não foram gravados no disco. A configuração padrão -1 seleciona um tamanho de 3% de shared_buffers, mas não menos que 64kB nem mais que o tamanho de um segmento WAL, normalmente 16MB. Portanto essa configuração não pode estar vazia.

### min_wal_size
Contanto que o uso do disco WAL permaneça abaixo dessa configuração, os arquivos WAL antigos serão sempre reciclados para uso futuro em um ponto de verificação, em vez de emovidos. Isso pode ser usado para garantir que espaço suficiente do WAL seja reservado para lidar com picos no uso do WAL, por exemplo, ao executar grandes trabalhos em lote. Se esse valor for especificado sem unidades, ele será considerado megabytes. O padrão é 80 MB.

### max_wal_size
Tamanho máximo para permitir que o WAL cresça durante checkpoints automáticos. O tamanho do WAL pode exceder max_wal_size em circunstâncias especiais, como carga pesada, causando falha no archive_command.

### default_statistics_target
É um parâmetro de configuração que determina o destino de estatísticas padrão para colunas da tabela que não possuem um destino explícito. 

### random_page_cost
Define a estimativa de processo do custo de uma página de disco que é consultada de forma não sequencial. O padrão é 4.0. 
Esse valor pode ser substituído para tabelas e índices em um tablespace específico definindo o parâmetro de tablespace de mesmo nome (consulte ALTER TABLESPACE ).
