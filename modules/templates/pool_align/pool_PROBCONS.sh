t_coffee -reg -reg_method probcons_msa -pool \
        -reg_tree ${guide_tree} \
        -seq ${seqs} \
        -reg_nseq ${bucket_size} \
        -reg_homoplasy \
        -outfile ${id}.pool_${bucket_size}.${align_method}.with.${tree_method}.tree.aln