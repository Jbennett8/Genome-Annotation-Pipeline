mkdir -p log

snakemake -p --rerun-incomplete --cluster \
'sbatch --partition={resources.partition} --ntasks={resources.ntasks} \
--qos={resources.qos} --job-name={params.jobName} \
--output=log/{params.jobName} --mem={resources.mem} \
--cpus-per-task={resources.cpus} $(bin/aux/./parseJobID.sh {dependencies})'\
 --jobs 100 --immediate-submit --notemp 2>&1 | tee temp.txt

# parse jobID's so we can run seff on completed jobs
echo $(date) >> submitted_jobIDs.txt && \
cat temp.txt | bin/aux/./parseSnakemakeSubmit.sh >> submitted_jobIDs.txt && \
rm temp.txt

