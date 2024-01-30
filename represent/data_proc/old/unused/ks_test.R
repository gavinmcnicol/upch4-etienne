#  KS test

# Calculate p-value based on KS-test
for_ks_t <- towers_coords_df_acquired[, 14:24]
for_ks_b <- bioclim_stack_df[, 1:11]

for (j in 1:ncol(for_ks_b)) {
  print(names(for_ks_b[j]))
  print(ks.test(for_ks_t[j], for_ks_b[, j], "pnorm"))
}




