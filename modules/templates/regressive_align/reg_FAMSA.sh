t_coffee -reg -reg_method famsa_msa \
         -reg_tree ${guide_tree} \
         -seq ${seqs} \
         -reg_nseq ${bucket_size} \
         -reg_homoplasy \
         -output fastaz_aln \
         -outfile ${id}.reg_${bucket_size}.${align_method}.with.${tree_method}.tree.aln
