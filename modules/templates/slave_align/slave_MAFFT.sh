export NO_MAFFT_BINARIES=1
export MAFFT_BINARIES=''

t_coffee -reg -reg_method mafft_msa \
         -reg_tree ${guide_tree} \
         -child_tree ${slave_method} \
         -seq ${seqs} \
         -reg_nseq ${bucket_size} \
         -reg_homoplasy \
         -outfile ${id}.slave_${bucket_size}.${align_method}.with.${tree_method}_${slave_method}.tree.aln
