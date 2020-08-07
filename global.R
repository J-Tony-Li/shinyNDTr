# to do
#

# I am definitely using these
library('shinydashboard')

# I am using these but might abandon these
library("plotrix")
library('fields')

# I should use these
library('ggplot2')
library('dplyr')
library('plotly')

rm(list=ls())

# https://groups.google.com/forum/#!msg/shiny-discuss/rU3vwGMZexQ/zeKhiYXrtEQJ
# settng the uploaded file size limit to 1 GB
options(shiny.maxRequestSize=1000*1024^2)

# working directoy is initialized as the dir of run file
# setwd("..")
# setwd("../NDTr")
# setwd("C:/Users/14868/Documents/GitHub/NDTr")
# setwd("/cbcl/cbcl01/xf15/NDTr")
# !
state_base_dir <- file.path(eval(getwd()))
raster_base_dir <- file.path(eval(getwd()),'data/raster') #"."
binned_base_dir <- file.path(eval(getwd()),'data/binned') #"."
#script_base_dir <- file.path(eval(getwd()),'scripts') #"."
result_base_dir <- file.path(eval(getwd()),'results') #"."
www_base_dir <- file.path(eval(getwd()),'www') #"."

script_base_dir <- file.path('scripts') #"."


# all_cl <- c("maximum correlation", "support vecotor machine", "poisson naive bayes")
# all_fp <- c("select_pvalue_significant_features","select or exclude top k features", "zscore_normalize")

# df_cl_fp <- data.frame(c(1, 1, 1), c(1, 1, 1), c(1, 1, 0))

#all_cl <- c("max_correlation_CL", "svm_CL", "poisson_naive_bayes_CL")
all_cl <- c("cl_max_correlation", "cl_svm", "cl_poisson_naive_bayes")

#all_fp <- c("select_k_features_FP", "zscore_FP")
all_fp <- c("fp_select_k_features", "fp_zscore")



all_result_type <- c("zero_one_loss", "normalized_rank", "decision_values", "all")

df_cl_fp <- data.frame(c(1, 1), c(1, 1), c(1, 0))

colnames(df_cl_fp) <- all_cl
rownames(df_cl_fp) <- all_fp

req_dc_para <- c("CL", "CV_bDiag", "CV_repeat", "CV_resample", "CV_split", "DS_chosen_bin", "DS_type")

# req_dc_para_basic <-c("DS_bUse_all_levels")
#
# req_dc_para_basic_leve <- c()

all_input <- list()
input_id <- c("Plot_create_pdf","home_state_name","home_loaded_state","home_save_state","Plot_chosen_result","DC_to_be_saved_result_name", "DC_script_mode","DC_to_be_saved_script_name","DS_save_binned_to_disk","DC_save_script_to_disk","bin_save_raster_to_disk","bin_create_raster",
              "bin_bin_data", "bin_bin_width", "bin_bPlot", "bin_chosen_raster",
              "bin_end_ind", "bin_next_neuron", "bin_prefix_of_binned_file_name",
              "bin_new_raster",
              "bin_pre_neuron", "bin_raster_end_ind","bin_raster_start_ind",
              "bin_start_ind", "bin_step_size",
  "bin_uploaded_raster","bin_uploaded_raster_name",
  "CL", "CL_SVM_coef0", "CL_SVM_cost", "CL_SVM_degree",
  "CL_SVM_gamma", "CL_SVM_kernel", "CV_bDiag", "CV_repeat", "CV_resample",
  "CV_split","DC_chosenscript_name", "DC_run_decoding", "DC_save_displayed_script", "DC_scriptize","DC_uploaded_script_name", "DS_basic_level_to_use", "DS_basic_var_to_decode", "DS_bUse_all_levels",
  "DS_chosen_bin", "DS_gen_num_training_level_groups", "DS_gen_var_to_decode",
  "DS_gen_var_to_use", "DS_type", "DS_uploaded_binned", "DS_uploaded_binned_name","FP", "FP_excluded_k",
  "FP_selected_k", "Plot_timeseries_result_type", "",
  "script", "sidebarCollapsed", "sidebarItemExpanded")


input_label <- c("Create","File name of the current state should be saved (e.g., state_01.Rda)","Load a pre-existing state","Save the current state","Browse", "File name of the result to be saved (e.g., my_results)","File type for generated script","File name of the displayed script to be saved (e.g., ZD_01.Rmd)", "Save to disk","Save to disk","Save to disk",
  "Create raster",
                 "Bin the data", "Bin width", "Plot the data? (only for spike trains in .Rda file)", "Browse",
                 "Index of the sample where the last bin ends (optional)", "next file","prefix of binned file name (e.g., ZD)",
                 "New raster directory name (e.g., data/raster/Zhang_Desimone_7objects_raster_data_rda; by default, we append '_rda' to the matlab raster directory name)",
                 "previous file", "Index of the sample where the new raster data end","Index of the sample where the new raster data begin",
                 "Index of the sample where the first bin starts (optional)", "Step size",
                 "Upload a zipped file raster data)", "Where you want the file to be unzipped",
                 "Classifier", "Coef0", "Cost", "Degree of polynomial",
                 "Gamma", "Kernel", "Test only at training times?", "Number of repeats of each level in each CV split", "Number of resampling runs",
                 "Number of cross validation split", "Browse","Save the script and run decoding", "Only save the script", "Generate script","Where you want this file to be saved", "Levels to use", "Variable to decode and to use", "Use all the levels of this variable?",
                 "Browse", "How many training level groups you will use?",  "Variable to decode",
                 "Variable to use", "Type of data source", "Upload new binned data (optional)", "Where you want this file to be saved", "Feature Preprocessors", "exclude top ? features (this will be applied second)",
                 "select top ? features (this will be applied first)", "Type of result to plot", "Type of result to plot",
                 NA, NA, NA)

lLabels <- as.list(input_label)
names(lLabels) <- input_id

binning_paras <- paste0("input$",c("bin_bin_width","bin_chosen_raster","bin_end_ind","bin_start_ind", "bin_step_size"))


temp_decoding_paras_id <<- c("CL", "CL_SVM_coef0", "CL_SVM_cost", "CL_SVM_degree",
                             "CL_SVM_gamma", "CL_SVM_kernel", "CV_bDiag", "CV_repeat", "CV_resample",
                             "CV_split", "CV_repeat", "CV_resample", "CV_split", "DS_basic_level_to_use", "DS_basic_var_to_decode", "DS_bUse_all_levels",
                             "DS_chosen_bin", "DS_gen_num_training_level_groups", "DS_gen_var_to_decode",
                             "DS_gen_var_to_use", "DS_type","FP", "FP_excluded_k",
                             "FP_selected_k")

temp_decoding_paras_input_id <<- paste0("input$", temp_decoding_paras_id)



move_file <- function(from, to) {
  todir <- dirname(to)
  if (!isTRUE(file.info(todir)$isdir)) dir.create(todir, recursive=TRUE)
  file.rename(from = from,  to = to)
}

preprocess_paras <- function(my_decoding_params){
  print("attach path")

  my_decoding_params$DC_to_be_saved_result_name <- file.path(result_base_dir,my_decoding_params$DC_to_be_saved_result_name)

  return(my_decoding_params)
}







convert_r_into_rmd <- function(text){

  my_text = ""

  my_text = paste0(my_text, "---\ntitle: 'Decoding Analysis'\noutput: pdf_document\n---\n\n\n", "```{r setup, include=FALSE}\n\n\n", "knitr::opts_chunk$set(echo = TRUE)\n\n\n", "```\n\n\n")

  my_text = paste0(my_text, "\n\n\n```{r}\n\n\n")

  my_text = paste0(my_text, text)



  my_text = paste0(my_text, "\n\n\n```\n\n\n")



  return(my_text)
}






create_script_in_rmd <- function(my_decoding_params, rv) {

r_text <- create_script_in_r(my_decoding_params, rv)

rmd_text <- convert_r_into_rmd(r_text)


return(rmd_text)

}










append_result_to_pdf_and_knit <- function(result_chosen, Plot_timeseries_result_type){

  my_new_file_name = file.path(www_base_dir, basename(paste0(substr(basename(result_chosen), 1,nchar(basename(result_chosen))-3), "Rmd")))

  file.create(my_new_file_name,  overwrite = TRUE)

  potential_rmd_name <- file.path(script_base_dir, paste0(substr(basename(result_chosen), 1,nchar(basename(result_chosen))-3), "Rmd"))

  if(file.exists(potential_rmd_name)){
    # my_text = paste(readLines(potential_rmd_name), collapse = "")
    my_text = sourcetools::read(potential_rmd_name)

  } else{
    potential_r_name <- file.path(script_base_dir, paste0(substr(basename(result_chosen), 1,nchar(basename(result_chosen))-3), "R"))
    # my_text = paste(readLines(potential_r_name), collapse = "")
    my_text = sourcetools::read(potential_r_name)

    my_text = convert_r_into_rmd(my_text)
  }


  my_text = paste0(my_text,"```{r}\n\n\n")

  my_text = paste0(my_text,"selected_result <- DECODING_RESULTS$", Plot_timeseries_result_type, "\n\n\n")

  my_text = paste0(my_text, "selected_mean_results <- colMeans(selected_result)\n\n\n")


  my_text = paste0(my_text,"selected_time_bin_names <- NDTr::get_center_bin_time(dimnames(selected_result)[[3]])\n\n\n")

  my_text = paste0(my_text,"image.plot(selected_time_bin_names, selected_time_bin_names, selected_mean_results, legend.lab = 'Classification Accuracy', xlab = 'Test time (ms)', ylab = 'Train time (ms)'')\n\n\n")

  my_text = paste0(my_text, "abline(v = 0)\n\n\n```")

  write(my_text, file = my_new_file_name)

  print(my_text)

  rmarkdown::render(my_new_file_name, "pdf_document")

}





create_pdf_including_result_upon_run_decoding <- function(potential_rmd_name ){

  message("currently not using create_pdf_including_result_upon_run_decoding() global.R function")

  #my_new_file_name = file.path(www_base_dir, DC_to_be_saved_script_name)
  #file.create(my_new_file_name,  overwrite = TRUE)
  #potential_rmd_name <- file.path(script_base_dir, DC_to_be_saved_script_name)

  # my_text = paste(readLines(potential_rmd_name), collapse = "")
  my_text = sourcetools::read(potential_rmd_name)



  my_text = paste0(my_text,"```{r}\n\n\n")

  my_text = paste0(my_text,"selected_result <- DECODING_RESULTS$zero_one_loss_results\n\n\n")

  my_text = paste0(my_text, "selected_mean_results <- colMeans(selected_result)\n\n\n")


  my_text = paste0(my_text,"selected_time_bin_names <- NDTr::get_center_bin_time(dimnames(selected_result)[[3]])\n\n\n")

  my_text = paste0(my_text,"image.plot(selected_time_bin_names, selected_time_bin_names, selected_mean_results, legend.lab = 'Classification Accuracy', xlab = 'Test time (ms)', ylab = 'Train time (ms)')\n\n\n")

  my_text = paste0(my_text, "abline(v = 0)\n\n\n```")

  write(my_text, file = my_new_file_name)

  print(my_text)

  rmarkdown::render(my_new_file_name, "pdf_document")

}










# create matlab script...

create_script_in_r <- function(my_decoding_params, rv) {


  print(names(my_decoding_params))

  my_decoding_params = preprocess_paras(my_decoding_params)

  my_text = ""




  my_text = paste0(my_text, "binned_file_name <-", "'",rv$binned_file_name,"'", "\n\n\n")




  if(my_decoding_params$DS_type == "basic_DS"){
    my_text = paste0(my_text, "variable_to_decode <-", "'",my_decoding_params$DS_basic_var_to_decode,"'", "\n\n\n")
    my_text = paste0(my_text, "num_cv_splits <- ", my_decoding_params$CV_split, "\n\n\n")

    my_text = paste0(my_text, "ds <- NDTr::ds_basic(binned_file_name, variable_to_decode, num_cv_splits,
                     num_label_repeats_per_cv_split = ", my_decoding_params$CV_repeat,")\n\n\n")


    # this one is bad because level_to_use can be passed from the previous selection
    # if(!is.null(my_decoding_params$DS_basic_level_to_use)){
    if(!my_decoding_params$DS_bUse_all_levels){
      my_text = paste0(my_text, "ds$level_to_use <- ", deparse(dput(my_decoding_params$DS_basic_level_to_use)), "\n\n\n")
    }
  }




  # my_text = paste0(my_text, "```\n\n\n")
  # my_text = paste0(my_text, "\n\n\n```{r}\n\n\n")


  my_text = paste0(my_text, "cl <- NDTr::", my_decoding_params$CL, "()\n\n\n")


  # my_text = paste0(my_text, "```\n\n\n")
  # my_text = paste0(my_text, "\n\n\n```{r}\n\n\n")


  my_text = paste0(my_text, "fps <- list(")


  select_k_text = ""
  norm_text = ""

  if(!is.null(my_decoding_params$FP)){
    if(sum(grepl(all_fp[2], my_decoding_params$FP)) == 1){
      norm_text = paste0(norm_text, "NDTr::", all_fp[2], "()")
      my_text = paste0(my_text, norm_text, ",")
    }

    if(sum(grepl(all_fp[1], my_decoding_params$FP)) == 1){
      select_k_text = paste0(select_k_text, "NDTr::", all_fp[2], "(","num_sites_to_use = ", my_decoding_params$FP_selected_k, ",", "num_sites_to_exclude = ", my_decoding_params$FP_excluded_k,")" )
      my_text = paste0(my_text, select_k_text)
    } else {
      my_text = substr(my_text, 1, nchar(my_text)-1)

    }
  }

  # browser()
  my_text = paste0(my_text, ")\n\n\n")


  # my_text = paste0(my_text, "```\n\n\n")
  # my_text = paste0(my_text, "\n\n\n```{r}\n\n\n")

  #my_text = paste0(my_text, "cv <- NDTr::cv_standard(ds, cl, fps)\n\n\n")
  my_text = paste0(my_text, "cv <- NDTr::cv_standard(ds, cl, fps, NULL, 2)\n\n\n")



  # my_text = paste0(my_text, "```\n\n\n")
  # my_text = paste0(my_text, "\n\n\n```{r}\n\n\n")


  my_text = paste0(my_text, "DECODING_RESULTS <- NDTr::run_decoding(cv)\n\n\n")

  # my_text = paste0(my_text, "save('DECODING_RESULTS', file = '", my_decoding_params$DC_to_be_saved_result_name, "')")


  my_text = paste0(my_text, "'Decodings results analysis ID:'\n")
  my_text = paste0(my_text, "DECODING_RESULTS$cross_validation_paramaters$analysis_ID \n\n\n")

  analysis_name <- "my_analysis"
  my_text = paste0(my_text, "NDTr::log_save_results(DECODING_RESULTS, '", rv$result_base_dir, "')")

  my_text = paste0(my_text, "\n\n\nplot(DECODING_RESULTS$rm_main_results)")

  #my_text = paste0(my_text, "```\n\n\n")



  return(my_text)

}





# create the script code for running a Matlab analysis

create_script_in_matlab <- function(my_decoding_params, rv) {



  print(names(my_decoding_params))

  my_decoding_params = preprocess_paras(my_decoding_params)

  my_text = "% add the path to the NDT so add_ndt_paths_and_init_rand_generator can be called
toolbox_basedir_name = 'ndt.1.0.4/'
addpath(toolbox_basedir_name);

% add the NDT paths using add_ndt_paths_and_init_rand_generator
add_ndt_paths_and_init_rand_generator"



  my_text = paste0(my_text, "binned_file_name =", "'",rv$binned_file_name,"'", "\n\n\n")



  if(my_decoding_params$DS_type == "basic_DS"){
    my_text = paste0(my_text, "specific_binned_label_name =", "'",my_decoding_params$DS_basic_var_to_decode,"';", "\n\n\n")
    my_text = paste0(my_text, "num_cv_splits = ", my_decoding_params$CV_split, ";\n\n\n")

    my_text = paste0(my_text, "ds = basic_DS(binned_file_name, variable_to_decode, num_cv_splits);\n\n\n")
    my_text = paste0(my_text, "ds.num_repeats_per_level_per_cv_split = ", my_decoding_params$CV_repeat, ";\n\n\n")

    # this one is bad because level_to_use can be passed from the previous selection
    # if(!is.null(my_decoding_params$DS_basic_level_to_use)){
    if(!my_decoding_params$DS_bUse_all_levels){
      my_text = paste0(my_text, "ds.lable_names_to_use <- ", deparse(dput(my_decoding_params$DS_basic_level_to_use)), ";\n\n\n")
    }
  }




  # my_text = paste0(my_text, "```\n\n\n")
  # my_text = paste0(my_text, "\n\n\n```{r}\n\n\n")


  my_text = paste0(my_text, "cl = ", my_decoding_params$CL, ";\n\n\n")


  # my_text = paste0(my_text, "```\n\n\n")
  # my_text = paste0(my_text, "\n\n\n```{r}\n\n\n")


  my_text = paste0(my_text, "fps = {")


  select_k_text = ""
  norm_text = ""

  if(!is.null(my_decoding_params$FP)){
    if(sum(grepl(all_fp[2], my_decoding_params$FP)) == 1){
      norm_text = paste0(norm_text, all_fp[2])
      my_text = paste0(my_text, norm_text, ",")
    }

    if(sum(grepl(all_fp[1], my_decoding_params$FP)) == 1){
      select_k_text = paste0(select_k_text, "NDTr::", all_fp[2], "(","num_sites_to_use = ", my_decoding_params$FP_selected_k, ",", "num_sites_to_exclude = ", my_decoding_params$FP_excluded_k,")" )
      my_text = paste0(my_text, select_k_text)
    } else {
      my_text = substr(my_text, 1, nchar(my_text)-1)

    }
  }

  # browser()
  my_text = paste0(my_text, "};\n\n\n")


  # my_text = paste0(my_text, "```\n\n\n")
  # my_text = paste0(my_text, "\n\n\n```{r}\n\n\n")

  my_text = paste0(my_text, "cv = standard_resample_CV(ds, cl, fps);\n\n\n")



  # my_text = paste0(my_text, "```\n\n\n")
  # my_text = paste0(my_text, "\n\n\n```{r}\n\n\n")


  my_text = paste0(my_text, "DECODING_RESULTS =  cv.run_cv_decoding;\n\n\n")

  my_text = paste0(my_text, "save('", my_decoding_params$DC_to_be_saved_result_name, "', DECODING_RESULTS", ");")

  # my_text = paste0(my_text, "```\n\n\n")



  return(my_text)

}  # end create Matlab analysis...










