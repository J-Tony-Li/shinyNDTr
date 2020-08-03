


function(input, output, session) {

  # shinyFileChoose(input, 'files', root=c(root='.'), filetypes=c('', 'txt'))
  # shinyDirChoose(input, "bin_chosen_raster", roots = c(wd='.'))

  # shinyDirChoose(input, "bin_chosen_raster")




  rv <- reactiveValues()

  rv$state_base_dir <- state_base_dir
  rv$state_cur_file_name <- ""

  rv$raster_base_dir <- raster_base_dir
  rv$raster_cur_dir_name <- NA
  rv$raster_cur_neuron <- 1
  rv$raster_num_neuron <- NA
  rv$raster_cur_file_name <- NULL
  rv$mRaster_cur_data <- NULL
  rv$raster_bRda <- FALSE
  rv$raster_bMat <-FALSE

  # !
  rv$create_bin_function_run <- ""
  rv$create_raster_function_run <- ""

  rv$binned_base_dir <- binned_base_dir
  rv$binned_file_name <- NA
  rv$binned_data <- NULL
  rv$binned_maximum_num_of_levels_in_all_var <- NULL
  rv$binned_all_var <- NULL

  rv$script_base_dir <- script_base_dir
  rv$script_chosen <- "No script chosen yet"
  rv$displayed_script <- ""

  rv$result_base_dir <- result_base_dir
  rv$result_chosen <- NA
  rv$result_data <- NULL


  rv$www_base_dir <- www_base_dir
  # only files meet specified files types will be shown. However, such dir shown as empty can still be choosed

  shinyFiles::shinyFileChoose(input, "home_loaded_state", roots = c(wd=state_base_dir), filetypes = "Rda")
  shinyFiles::shinyDirChoose(input, "bin_chosen_raster", roots = c(wd=raster_base_dir), filetypes = c("mat", "Rda"))
  shinyFiles::shinyFileChoose(input, "DS_chosen_bin", roots = c(wd=binned_base_dir), filetypes = "Rda")
  shinyFiles::shinyFileChoose(input, "DC_chosen_script_name", root =c(wd=script_base_dir, filetypes = c("R", "Rmd")))
  shinyFiles::shinyFileChoose(input, "Plot_chosen_result", root =c(wd=result_base_dir), filetypes = "Rda")

  output$home_offer_save_state = renderUI({
    list(
      textInput("home_state_name", lLabels$home_state_name, rv$state_base_dir),
      actionButton("home_save_state", lLabels$home_save_state),
      uiOutput("home_save_state_error")
    )
  })

  output$home_save_state_error = renderUI({
    er_home_save_state_error()
  })
  er_home_save_state_error <- eventReactive(input$home_save_state, {
    validate(
      need(input$home_state_name, paste0("Please tell me ", lLabels$home_state_name, " first!"))
    )
  })
  observeEvent(input$home_save_state, {
    req(input$home_state_name)
    state = reactiveValuesToList(input)
    save(state, file = input$home_state_name)

  })
observe({
#   req(input$home_loaded_state)
#   temp_state_file <- shinyFiles::parseFilePaths(c(wd=rv$state_base_dir), input$home_loaded_state)
#   req(temp_state_file$datapath)
#   rv$state_cur_file_name <-temp_state_file$datapath
#   load(rv$state_cur_file_name)
#   for(iInput in 1: length(state)){
#     input[[iInput]] <- state[iInput]
#   }
# lapply(state, function(i)){
#   do.call(update)
# }

})



  observe({
    req(input$bin_chosen_raster)

    rv$raster_cur_dir_name <- shinyFiles::parseDirPath(c(wd= rv$raster_base_dir),input$bin_chosen_raster)

    # # we need this second check because as soon as the buttin is clicked, an object instantiated and assigned to input$bin_chosen_raster
    # print(input$bin_chosen_raster)
    # print(rv$raster_cur_dir_name)
    req(rv$raster_cur_dir_name)

    print("lala")
    temp_names_of_all_mat_files_in_raster_dir <-
      list.files(rv$raster_cur_dir_name, pattern = "\\.mat$")
    #
    if(length(temp_names_of_all_mat_files_in_raster_dir) > 0){
      rv$raster_bMat <- TRUE

      # print(rv$raster_bMat)
      #

      # print("mat")
    } else {
      rv$raster_bMat <-FALSE
      temp_names_of_all_rda_files_in_raster_dir <-
        list.files(rv$raster_cur_dir_name, pattern = "\\.[rR]da$")
      rv$raster_num_neuron <- length(temp_names_of_all_rda_files_in_raster_dir)

      if(rv$raster_num_neuron > 0){
        rv$raster_bRda <- TRUE
        # print("rda")
        rv$raster_cur_file_name <- temp_names_of_all_rda_files_in_raster_dir[rv$raster_cur_neuron]
        load(file.path(rv$raster_cur_dir_name, rv$raster_cur_file_name))

        # # the following code makes this observe keeps executing, don't know why
        # temp_dfRaster <- select(raster_data, starts_with("time."))
        # rv$mRaster_cur_data <- as.matrix(temp_dfRaster)
        # rownames(rv$mRaster_cur_data) <- 1:dim(rv$mRaster_cur_data)[1]
        # colnames(rv$mRaster_cur_data) <- gsub("time.", "", colnames(rv$mRaster_cur_data))
        # # using the following instead
        temp_dfRaster <- select(raster_data, starts_with("time."))
        temp_mRaster <- as.matrix(temp_dfRaster)
        rownames(temp_mRaster) <- 1:dim(temp_mRaster)[1]
        colnames(temp_mRaster) <- gsub("time.", "", colnames(temp_mRaster))
        rv$mRaster_cur_data <- temp_mRaster

        # rv$mRaster_cur_data <- select(raster_data, starts_with("time."))
        # print(head(rv$raster_cur_data))
      } else{
        # print("none")
        rv$raster_bRda <- FALSE
        # this doesn't work; observe is for action not calculation
        # validate("Only accept raster data in .mat or .Rda format !")

      }
    }
  })

  observe({
    req(input$DS_chosen_bin)
    temp_df_file <- shinyFiles::parseFilePaths(c(wd= rv$binned_base_dir),input$DS_chosen_bin)
    # print(temp_df_file)
    req(temp_df_file$datapath)
    rv$binned_file_name <- temp_df_file$datapath

    load(rv$binned_file_name)
    rv$binned_data <- binned_data
    rv$binned_maximum_num_of_levels_in_all_var <-
      max(apply(select(binned_data, starts_with("labels"))[,],2, function(x) length(levels(as.factor(x)))))
    rv$binned_all_var <- sub("labels.", "", names(select(binned_data, starts_with("labels"))))

  })

  observe({

    req(input$DC_chosen_script_name)


    temp_df_file <- shinyFiles::parseFilePaths(c(wd= rv$script_base_dir),input$DC_chosen_script_name)
    # print(temp_df_file)
    req(temp_df_file$datapath)
    rv$script_chosen <- temp_df_file$datapath
    rv$displayed_script <- readChar(rv$script_chosen, file.info(rv$script_chosen)$size)
    updateTextInput(session, "DC_chosen_script_name", value = rv$script_chosen)
  })

  # when unzip a file, the new file is unzipped to exdir with origianl name, thus there is no need to update input with chosen file name
  # observe({
  #   req(input$bin_uploaded_raster)
  #   temp_file_name <-input$bin_uploaded_raster$datapath
  #   print(temp_file_name)
  #
  #   updateTextInput(session, "bin_uploaded_raster_name", value = file.path(rv$raster_base_dir, basename(temp_file_name)))
  # })



  observe({

    req(input$DC_to_be_saved_result_name)
    if(input$DC_script_mode == "R Markdown"){
      print(update)
      updateTextInput(session, "DC_to_be_saved_script_name", value = paste0(substr(input$DC_to_be_saved_result_name, 1,nchar(input$DC_to_be_saved_result_name)-3), "Rmd"))
    } else{
      updateTextInput(session, "DC_to_be_saved_script_name", value = paste0(substr(input$DC_to_be_saved_result_name, 1,nchar(input$DC_to_be_saved_result_name)-3), "R"))
    }
  })

  observe({
    req(input$Plot_chosen_result)
    temp_df_file <- shinyFiles::parseFilePaths(c(wd= rv$result_base_dir),input$Plot_chosen_result)
    # print(temp_df_file)
    req(temp_df_file$datapath)
    rv$result_chosen <- temp_df_file$datapath
    load(rv$result_chosen)
    rv$result_data <- DECODING_RESULTS

  })

  observeEvent(input$bin_save_raster_to_disk, {
    req(input$bin_uploaded_raster,input$bin_uploaded_raster_name )
    unzip(input$bin_uploaded_raster$datapath, exdir=input$bin_uploaded_raster_name)


  })
  observe({
    req(input$DS_uploaded_binned)
    temp_file_name <-input$DS_uploaded_binned$datapath
    updateTextInput(session, "DS_uploaded_binned_name", value = file.path(rv$binned_base_dir, basename(temp_file_name)))
  })

  observeEvent(input$DS_save_binned_to_disk, {
    req(input$DS_uploaded_binned,input$DS_uploaded_binned_name )
    move_file(input$DS_uploaded_binned$datapath,input$DS_uploaded_binned_name )


  })





  observeEvent(input$DC_save_displayed_script,{
    req(input$DC_to_be_saved_script_name, rv$displayed_script)
    temp_file_name = file.path(script_base_dir, input$DC_to_be_saved_script_name)
    file.create(temp_file_name, overwrite = TRUE)
    write(rv$displayed_script, file = temp_file_name)
  })

  rv$script_rmd_not_saved_yet <- 1

  # er_DC_rmd_not_saved_before_decoding_error <- eventReactive(rv$script_rmd_not_saved_yet,{
  #   validate("Please save the script in R Mardown first !")
  # })



  observeEvent(input$DC_run_decoding, {

    req(input$DC_to_be_saved_script_name, rv$displayed_script)
    file.create(file.path(script_base_dir, input$DC_to_be_saved_script_name), overwrite = TRUE)
    write(rv$displayed_script, file = file.path(script_base_dir,input$DC_to_be_saved_script_name))

    if(input$DC_script_mode == "R Markdown"){
0

      # if(!(file.exists(input$DC_to_be_saved_script_name) && tools::file_ext(input$DC_to_be_saved_script_name) == "Rmd" || tools::file_ext(input$DC_to_be_saved_script_name) == "rmd" )){
      #   rv$script_rmd_not_saved_yet <- rv$script_rmd_not_saved_yet * (-1)
      # } else{
      # rmarkdown::render(file.path(script_base_dir,input$DC_to_be_saved_script_name))
      create_pdf_including_result_upon_run_decoding(input$DC_to_be_saved_script_name)

      # }

    } else{
      # eval(parse(text = rv$displayed_script))
      source(file.path(script_base_dir,input$DC_to_be_saved_script_name))

    }
  })



  observeEvent(input$bin_bin_data,{

print(typeof(input$bin_bin_data))

    if(rv$raster_bRda){

      # data binned data in the director data/binned
      binned_basename <- trimws(file.path("data", "binned", " "))

      # print(input$bin_start_ind)
      temp_call = paste0("NDTr::create_binned_data(rv$raster_cur_dir_name, ",
                         "paste0(binned_basename, input$bin_prefix_of_binned_file_name),",
                         "input$bin_bin_width, input$bin_step_size")
      if(!is.na(input$bin_start_ind)){
        temp_call = paste0(temp_call, ",input$bin_start_ind")
      }
      if(!is.na(input$bin_end_ind)){
        temp_call = paste0(temp_call, ",input$bin_end_ind")
      }
      temp_call = paste0(temp_call,")")
      rv$create_bin_function_run <- temp_call
      eval(parse(text = temp_call))

    } else if(rv$raster_bMat){

      temp_call = paste0("NDTr::create_binned_data_from_matlab_raster_data(rv$raster_cur_dir_name,",
                         "input$bin_prefix_of_binned_file_name,",
                         "input$bin_bin_width, input$bin_step_size")
      if(!is.na(input$bin_start_ind)){
        temp_call = paste0(temp_call, ",input$bin_start_ind")
      }
      if(!is.na(input$bin_end_ind)){
        temp_call = paste0(temp_call, ",input$bin_end_ind")
      }
      temp_call = paste0(temp_call,")")
      rv$create_bin_function_run <- temp_call
      eval(parse(text = temp_call))

    }

  })

  observeEvent(input$bin_create_raster,{

    temp_call = paste0("NDTr::create_raster_data_from_matlab_raster_data(rv$raster_cur_dir_name,",
                       "input$bin_new_raster")
    if(!is.na(input$bin_start_ind)){
      temp_call = paste0(temp_call, ",input$bin_raster_start_ind")
    }
    if(!is.na(input$bin_end_ind)){
      temp_call = paste0(temp_call, ",input$bin_raster_end_ind")
    }
    temp_call = paste0(temp_call,")")
    rv$create_raster_funciton_run <- temp_call
    eval(parse(text = temp_call))


  })




  rv_para <- reactiveValues()

  # decoding_para_id changes. This is used by observerEvent who figures out the ids to signal eventReactive to check if they are in position
  rv_para$decoding_para_id_computed <- 1



  observeEvent(input$DC_scriptize,{

    # refresh rv_para$id
    rv_para$id <-  c("DS_chosen_bin", "DS_type","CL", "CV_repeat", "CV_resample","CV_split", "DC_to_be_saved_result_name")
    # rv_para$id <-  c("rv$binned_file_name", "DS_type","CL", "CV_repeat", "CV_resample","CV_split", "DC_to_be_saved_result_name")
    if(input$DS_type == "basic_DS"){
      rv_para$id <- c(rv_para$id,"DS_basic_var_to_decode")
      if(!input$DS_bUse_all_levels){
        rv_para$id <- c(rv_para$id,  "DS_basic_level_to_use")
      }
    } else{
      rv_para$id <- c(rv_para$id,"DS_gen_var_to_use","DS_gen_var_to_decode", "DS_gen_num_training_level_groups")
    }

    rv_para$inputID <- paste0("input$", rv_para$id)

    rv_para$decoding_para_id_computed <- rv_para$decoding_para_id_computed * (-1)
    eval(parse(text = paste0("req(", rv_para$inputID, ")")))
    #     # !
    # do.call(req, as.list(rv_para$inputID))

    # print("do")

    rv_para$id_of_useful_paras <- c(rv_para$id, "CL_SVM_coef0", "CL_SVM_cost", "CL_SVM_degree",
                                    "CL_SVM_gamma", "CL_SVM_kernel", "CV_bDiag", "DS_bUse_all_levels","FP", "FP_excluded_k",
                                    "FP_selected_k")

    # this one is bad because level_groups can be passed from the previous selection
    # if(!is.null(input$DS_gen_num_training_level_groups)){
    if(input$DS_type == "generalization_DS"){
      temp_training_level_groups <- paste0("input$DS_training_level_group_", c(1:input$DS_gen_num_training_level_groups))
      temp_testing_level_groups <- paste0("input$DS_testing_level_group_", c(1:input$DS_gen_num_testing_level_groups))
      rv_para$id_of_useful_paras <- c(rv_para$id_of_useful_paras, trainin_level_groups, testing_level_groups)
    }
    rv_para$inputID_of_useful_paras <- paste0("input$", rv_para$id_of_useful_paras)

    rv_para$values <- lapply(rv_para$inputID_of_useful_paras, function(i){
      eval(parse(text = i))
    })

    # print(rv_para$values)
    lDecoding_paras <- as.list(rv_para$values)
    lDecoding_paras <- setNames(lDecoding_paras, rv_para$id_of_useful_paras)

    # print(lDecoding_paras)
    # print(lDecoding_paras$CL)

    if(input$DC_script_mode == "R Markdown"){
      rv$displayed_script <- create_script_in_rmd(lDecoding_paras, rv)
    } else if (input$DC_script_mode == "R") {
      rv$displayed_script <- create_script_in_r(lDecoding_paras, rv)
    } else if (input$DC_script_mode == "Matlab") {
      rv$displayed_script <- create_script_in_matlab(lDecoding_paras, rv)
      #print('blah')
    }



  })


  er_scriptize_action_error <- eventReactive(rv_para$decoding_para_id_computed,{
# if we don't have this line, this function will be called as soon as users click the script tab because rv_para$decoding_para_id_computed is going from NULL to 1 (I think)
    req(rv_para$id)
    # my_decoding_paras <<- paste0("my_",decoding_paras)
validate(
  need(input$DS_chosen_bin, "Did you not even choose the binned data?")
)
    temp_need = lapply(rv_para$id, function(i){
      eval(parse(text = paste0("need(input$", i, ", '", "You need to set ",eval(parse(text = paste0("lLabels$", i))), "')")))
    })


    do.call(validate, temp_need)


  })
  output$DC_scriptize_error <- renderText({
    er_scriptize_action_error()

  })



  observeEvent(input$bin_pre_neuron,{
    if(rv$raster_cur_neuron > 1){
      rv$raster_cur_neuron <- rv$raster_cur_neuron - 1
      # print("pre")
      # print(rv$raster_cur_neuron)

    }

  })

  observeEvent(input$bin_next_neuron,{
    if(rv$raster_cur_neuron < rv$raster_num_neuron){
      rv$raster_cur_neuron <- rv$raster_cur_neuron + 1
      # print(rv$raster_num_neuron)
      # print("next")
      # print(rv$raster_cur_neuron)

    }
  })



  reactive_validate_for_scriptizing <- reactive({

  })

  reactive_bRaster_qualified <- reactive({
    sum(rv$raster_bMat, rv$raster_bRda)
    # validate(
    #   need(!rv$raster_deamon, "Only accept .mat and .Rda format!! Please change your dataset")
    # )
  })

  reactive_bin_num_neuron <- reactive({

    # this error message doesn't show up now since datasource is on the first tab and DS is selected. I keep it here
    # as an example of using validate
    validate(
      need(input$DS_chosen_bin,"Please select data source first to get total number of neurons!")
    )
    binned_data = rv$binned_data
    length(unique(factor(binned_data$siteID)))
  })






  reactive_all_levels_of_basic_var_to_decode <- reactive({
    req(rv$binned_file_name)


    binned_data = rv$binned_data
    # print(head(binned_data))
    # print(input$DS_var_to_decode)
    levels(factor(binned_data[[paste0("labels.",input$DS_basic_var_to_decode)]]))

    # }
  })

  reactive_all_levels_of_gen_var_to_use <- reactive({
    req(rv$binned_file_name)

    binned_data = rv$binned_data
    # print(head(binned_data))
    # print(input$DS_var_to_decode)
    levels(factor(binned_data[[paste0("labels.",input$DS_gen_var_to_use)]]))

    # }
  })

  reactive_all_fp_avail <- reactive({
    req(input$CL)
    all_fp[df_cl_fp[,input$CL]>0]
  })

  er_bin_action_error <- eventReactive(input$bin_bin_data,{
    validate(
      need(rv$raster_cur_dir_name, "You haven't chosen the raster data yet!")
    )

    validate(
      need(rv$raster_bRda||rv$raster_bMat, "We only accept .mat and .Rda format !")
    )
  })


  er_bin_save_raster_to_disk_error <- eventReactive(input$bin_save_raster_to_disk,{
    validate(
      need(input$bin_uploaded_raster, paste0("Please ", lLabels$bin_uploaded_raster, "!")),
      need(input$bin_uploaded_raster_name, paste0("Please tell me ", lLabels$bin_uploaded_raster_name))
    )
  })

  er_DS_save_binned_to_disk_error <- eventReactive(input$DS_save_binned_to_disk,{
    validate(
      need(input$DS_uploaded_binned, paste0("Please ", lLabels$DS_uploaded_binned, "!")),
      need(input$DS_uploaded_binned_name, paste0("Please tell me ", lLabels$DS_uploaded_binned_name))
    )
  })

  er_DC_save_displayed_script_error <- eventReactive(input$DC_save_displayed_script,{
    validate(
      need(rv$displayed_script,"Please generate the script first !"),
      need(input$DC_to_be_saved_script_name, paste0("Please tell me ",lLabels$DC_chosen_script_name))
    )
  })

  # er_DC_run_decoding_error <- eventReactive(input$DC_run_decoding, {
  #   validate(
  #     need(rv$displayed_script,"You haven't generated the script yet!"),
  #     need(rv$to_be_saved_script_name, "You haven't told me the file name for the script yet!")
  #   )
  # })

  # er_DC_to_be_saved_result_name_not_given_error <- eventReactive(input$DC_run_decoding, {
  #   validate(need(input$DC_to_be_saved_result_name, paste0("Please set ", lLabels$DC_to_be_saved_result_name, " first!")))
  # })
  output$bin_action_error = renderUI({
    er_bin_action_error()

  })

  output$bin_save_raster_to_disk_error = renderUI({

    er_bin_save_raster_to_disk_error()

  })
  output$DS_save_binned_to_disk_error = renderUI({

    er_DS_save_binned_to_disk_error()

  })
  # output$DC_save_script_to_disk_error = renderUI({
  #
  #   er_DC_save_script_to_disk_error()
  #
  # })

  output$DC_save_displayed_script_error = renderUI({
    er_DC_save_displayed_script_error()
  })


  output$DC_run_decoding_error = renderUI({
    er_DC_save_displayed_script_error()
    # er_DC_rmd_not_saved_before_decoding_error()
    # er_DC_to_be_saved_result_name_not_given_error()
  })
  output$where = renderDataTable(input$bin_uploaded_raster)



  output$bin_offer_upload_raster = renderUI({
    list(
      fileInput("bin_uploaded_raster", lLabels$bin_uploaded_raster, multiple = TRUE),

      textInput("bin_uploaded_raster_name", lLabels$bin_uploaded_raster_name, rv$raster_base_dir),
      actionButton("bin_save_raster_to_disk", lLabels$bin_save_raster_to_disk),
      uiOutput("bin_save_raster_to_disk_error")
    )


  })

  output$DS_offer_upload_bin = renderUI({
    list(
      fileInput("DS_uploaded_binned", lLabels$DS_uploaded_binned, multiple = TRUE),
      textInput("DS_uploaded_binned_name", lLabels$DS_uploaded_binned_name, rv$binned_base_dir),
      actionButton("DS_save_binned_to_disk",lLabels$DS_save_binned_to_disk),
      uiOutput("DS_save_binned_to_disk_error")

    )
  })




  # UI element to get the name of the file to be saved (I think)
  output$DC_offer_save_displayed_script = renderUI({
    list(
      textInput("DC_to_be_saved_script_name", lLabels$DC_to_be_saved_script_name),
      actionButton("DC_save_displayed_script", lLabels$DC_save_displayed_script),
      uiOutput("DC_save_displayed_script_error")
    )
  })




  output$DC_offer_scriptize = renderUI({
    list(

      textInput("DC_to_be_saved_result_name", lLabels$DC_to_be_saved_result_name),
      actionButton("DC_scriptize", lLabels$DC_scriptize),
      uiOutput("DC_scriptize_error")

    )
  })



  output$DC_offer_run_decoding = renderUI({
    list(
      helpText(""),
      actionButton("DC_run_decoding", lLabels$DC_run_decoding),
      uiOutput("DC_run_decoding_error")
    )
  })





  output$bin_offer_create_raster = renderUI({
    req(rv$raster_cur_dir_name)


    # req(input$bin_chosen_raster)
    if(rv$raster_bMat){
      # checkboxInput("bin_bCreate_raster_in_rda",lLabels$bin_bCreate_raster_in_rda)
      temp_matlab_raster_dir_name <- rv$raster_cur_dir_name
      # if the directory name ends with _mat, remove _mat
      temp_non_desired_pattern = '.*_mat$'
      if (grepl(temp_non_desired_pattern, temp_matlab_raster_dir_name) == TRUE){
        temp_r_raster_dir_name <- substr(temp_matlab_raster_dir_name, 1, nchar(temp_matlab_raster_dir_name) - 4)
      }

      # append Rda
      temp_r_raster_dir_name <- paste0(temp_r_raster_dir_name, "_rda/")

      list(
        helpText(paste0("We can bin raster data in .mat format, but do you want to create raster data in .Rda format? ",
                        "Benefits include the option to plot raster data ")),

        textInput("bin_new_raster", lLabels$bin_new_raster, temp_r_raster_dir_name),
        numericInput("bin_raster_start_ind", lLabels$bin_raster_start_ind, value = NULL),
        numericInput("bin_raster_end_ind", lLabels$bin_raster_end_ind, value = NULL),

        actionButton("bin_create_raster", lLabels$bin_create_raster))
    }
  })

  output$bin_evil_raster = renderUI({
    #
    req(rv$raster_cur_dir_name)
    validate(


      need(reactive_bRaster_qualified() > 0, "Only accept .mat and .Rda format!! Please change your dataset"))
  })





  output$bin_show_create_bin_function_run = renderText({
    rv$create_bin_function_run
  })




  output$bin_show_create_raster_function_run = renderText(({
    rv$create_raster_funciton_run
  }))




  output$bin_show_chosen_raster = renderText({
    # temp_text = "Chose raster"
    # rv$raster_cur_dir_name <- parseDirPath(c(wd=eval(getwd())),input$bin_chosen_raster)

    # we need this because it seems that as soon as you click file, sinyFiles first turns it into null then fill in
    req(rv$raster_cur_dir_name)
    if(is.na(rv$raster_cur_dir_name)){
      "No file chosen yet"
    } else{
      basename(rv$raster_cur_dir_name)

    }
  })




  output$bin_show_raster_cur_file_name = renderText({
    paste0("current data shown:", "\n", rv$raster_cur_file_name)

  })




  output$bin_raster_plot = renderPlot({
    # print(head(rv$raster_cur_data))
    # req(rv$raster_cur_data)
    # temp_raster <-rv$raster_cur_data
    #
    # color2D.matplot(1 - temp_raster, border = NA, xlab = "Time (ms)",
    #                 ylab = "Trial")
req(rv$mRaster_cur_data)
    temp_dfMelted <- reshape2::melt(rv$mRaster_cur_data)
    # magically, trials/rownames are oncverted from character to integer by melt. Times/colnames are also integer
    if(length(unique(factor(temp_dfMelted$value))) < 3){
      ggplot(temp_dfMelted, aes(x = Var2, y = Var1)) +
        geom_raster(aes(fill=factor(value))) +
        scale_fill_manual(values=c("0"="white", "1"="black"))+
        labs(x="Time (ms)", y="Trial")+
        theme(legend.position="none")
    } else {
      ggplot(temp_dfMelted, aes(x = Var2, y = Var1)) +
        geom_raster(aes(fill=value)) +
        scale_fill_gradient(low="grey90", high="red")+
        labs(x="Time (ms)", y="Trial")+
        theme(legend.position="none")
    }

  })





  output$bin_PSTH = renderPlot({
    # req(rv$raster_cur_data)

    # temp_raster <- rv$raster_cur_data
    # plot(colSums(temp_raster, na.rm = FALSE, dims = 1)/nrow(temp_raster),
    #      xlab = "Time(ms)", ylab = "average firing rate")

    req(rv$mRaster_cur_data)

    temp_mRaster_cur_data_mean <- colSums(rv$mRaster_cur_data, na.rm = FALSE, dims = 1)/nrow(rv$mRaster_cur_data)
    temp_dfRaster_mean <- data.frame(time = as.numeric(names(temp_mRaster_cur_data_mean)), spike_mean_over_trials = temp_mRaster_cur_data_mean)


    qplot(x = time, y = spike_mean_over_trials, data = temp_dfRaster_mean, geom = "point", color = "salmon1") +
      scale_x_continuous(breaks = temp_dfRaster_mean$time[c(TRUE, rep(FALSE, length(temp_dfRaster_mean$time)/10))]) +
      labs(x="Time (ms)", y="Spike Mean over Trials") +
      theme(legend.position="none")
  })





  output$DS_show_chosen_bin = renderText({
    if(is.na(rv$binned_file_name)){
      "No file chosen yet"
    } else{
      basename(rv$binned_file_name)

    }
  })




  output$DS_basic_list_of_var_to_decode = renderUI({
    req(rv$binned_file_name)

    selectInput("DS_basic_var_to_decode",
                lLabels$DS_basic_var_to_decode,
                rv$binned_all_var
                # c("")
    )

  })




  output$DS_gen_list_of_var_to_decode = renderUI({
    req(rv$binned_file_name)

    selectInput("DS_gen_var_to_decode",
                lLabels$DS_gen_var_to_decode,
                rv$binned_all_var
                # c("")
    )

  })





  output$DS_basic_list_of_levels_to_use = renderUI({

    selectInput("DS_basic_level_to_use",
                lLabels$DS_basic_level_to_use,
                reactive_all_levels_of_basic_var_to_decode(),
                multiple = TRUE)

  })
  #
  output$DS_gen_list_of_var_to_use = renderUI({
    req(rv$binned_file_name)

    selectInput("DS_gen_var_to_use",
                lLabels$DS_gen_var_to_use,
                rv$binned_all_var)
  })

  output$DS_gen_select_num_of_groups = renderUI({
    req(rv$binned_file_name)

    temp_max <- rv$binned_maximum_num_of_levels_in_all_var
    numericInput("DS_gen_num_training_level_groups",
                 lLabels$DS_gen_num_training_level_groups,
                 1,
                 min = 1,
                 max  = temp_max)
    # print(temp_max)
  })

  output$DS_gen_list_of_training_level_groups = renderUI({
    req(input$DS_gen_num_training_level_groups)
    temp_num <- input$DS_gen_num_training_level_groups
    # print(temp_num)
    # if(!is.null(temp_num)){
    temp_output <- lapply(1:temp_num, function(i){
      list(selectInput(paste0("DS_training_level_group_", i),
                       paste("Training level group", i),
                       reactive_all_levels_of_gen_var_to_use(),
                       multiple = TRUE
      ),
      selectInput(paste0("DS_testing_level_group_", i),
                  paste("Testing level group", i),
                  reactive_all_levels_of_gen_var_to_use(),
                  multiple = TRUE
      ))


    })
    # print(temp_output)
    temp_output <- unlist(temp_output, recursive = FALSE)
    # output <- do.call(c, unlist(temp_output, recursive=FALSE))
    # print(output)
    temp_output
    # }


  })







  output$FP_check_fp = renderUI({
    checkboxGroupInput("FP",
                       lLabels$FP,
                       reactive_all_fp_avail()
    )
  }
  )

  output$FP_select_k_features = renderUI({
    print(input$FP)
    if(sum(grepl(all_fp[1], input$FP))){
      # print("FP")
      numericInput("FP_selected_k",
                   lLabels$FP_selected_k,
                   reactive_bin_num_neuron(),
                   min = 1,
                   max = reactive_bin_num_neuron())
    }




  })

  # we don't put exclude together with select because the max of exclude is contigent on select. Therefore, we also need the req()
  output$FP_exclude_k_features = renderUI({

    req(input$FP_selected_k)
    numericInput("FP_excluded_k",
                 lLabels$FP_excluded_k,
                 0,
                 min = 1,
                 max = reactive_bin_num_neuron() - input$FP_selected_k)
  })

  reactive_DS_levels_to_use <- reactive({
    req(rv$binned_data)

    if(input$DS_type == "basic_DS"){
      validate(
        need(!is.null(input$DS_basic_level_to_use)||input$DS_bUse_all_levels, paste0("You haven't set ",
                                                                                     lLabels$DS_basic_level_to_use, " yet!"))
      )
      if(input$DS_bUse_all_levels){
        reactive_all_levels_of_basic_var_to_decode()

      } else{
        input$DS_basic_level_to_use

      }


    } else{
      temp_training_level_group_ids <- paste0("input$DS_training_level_group_", c(1:input$DS_gen_num_training_level_groups))
      temp_need <- lapply(temp_training_level_group_ids, function(i){
        eval(parse(text = paste0("need(", i, ", '", "You need to set ", eval(parse(text = paste0("lLabels$", i))), "')")))
      })
      do.call(validate, temp_need)

      temp_training_level_groups <- lapply(temp_training_level_group_ids, function(i){
        eval(parse(text = i))
      })
      unlist(temp_training_level_groups)


    }

  })




  reactive_level_repetition_info <- reactive({
    req(reactive_DS_levels_to_use())

    if(input$DS_type == "basic_DS"){

      num_label_reps <- NDTr::get_num_label_repetitions(rv$binned_data, input$DS_basic_var_to_decode, reactive_DS_levels_to_use())



    } else{

      NDTr::get_num_label_repetitions(rv$binned_data, input$DS_gen_var_to_use, reactive_DS_levels_to_use())

    }
  })




  output$CV_max_repetition_avail_with_any_site <- renderText({

    req(reactive_level_repetition_info())
    temp_level_repetition_info <- reactive_level_repetition_info()

        paste("Levels chosen for training:", "<font color='red'>", paste(reactive_DS_levels_to_use(), collapse = ', '),"<br/>", "</font>", "The maximum number of repetitions across all the levels for training as set on the Data Source tab is", "<font color='red'>",temp_level_repetition_info$max_repetition_avail_with_any_site, "</font>", ".")
  })


  output$CV_show_level_repetition_info <- renderPlotly({

    req(reactive_level_repetition_info())
    temp_level_repetition_info <- reactive_level_repetition_info()
    temp_level_repetition_info$plotly
  })



  reactive_chosen_repetition_info <- reactive({
    req(input$CV_split, input$CV_repeat, reactive_level_repetition_info())
    temp_level_repetition_info <- reactive_level_repetition_info()

    list(num_repetition = input$CV_repeat * input$CV_split,
       num_sites_avail = nrow(filter(temp_level_repetition_info$num_repeats_across_levels_per_site, min_repeats >= input$CV_repeat * input$CV_split)))
    })



  output$CV_repeat <- renderUI({
    # browser()
    numericInput("CV_repeat", lLabels$CV_repeat, value = 2, min = 1)
  })





  output$CV_split <- renderUI({
      numericInput("CV_split", lLabels$CV_split, value = 5, min = 2)
    })




  observe({
    req(reactive_level_repetition_info())
    temp_level_repetition_info <- reactive_level_repetition_info()
    updateNumericInput(session, "CV_repeat", max = floor(temp_level_repetition_info$max_repetition_avail_with_any_site/input$CV_split))
    updateNumericInput(session, "CV_split", max = floor(temp_level_repetition_info$max_repetition_avail_with_any_site/input$CV_repeat))
  })




  output$CV_show_chosen_repetition_info <- renderText({

    req(reactive_chosen_repetition_info())
    temp_chosen_repetition_info <- reactive_chosen_repetition_info()

    # paste("You selected", "<font color='red'>", temp_chosen_repetition_info$num_repetition, "</font>", "trials (). of all levels as set on the Data Source tab, which gives a total number of neurons available for decoding to be", "<font color='red'>", temp_chosen_repetition_info$num_sites_avail, "</font>", ".")
    paste("You selected", "<font color='red'>", temp_chosen_repetition_info$num_repetition, "</font>", "trials (", input$CV_repeat,  " repeats x ",  input$CV_split, "CV splits). Based on the levels selected Data source tab, this gives <font color='red'>", temp_chosen_repetition_info$num_sites_avail, "</font>", " sites available for decoding.")

  })





  output$DC_show_chosen_script = renderText({
    basename(rv$script_chosen)
  })



  output$DC_ace = renderUI({
    # print(rv$displayed_script)
    shinyAce::aceEditor("script",
                        rv$displayed_script,
                        # NULL,
                        mode = input$DC_script_mode)
  })




  output$DC_pdf <- renderUI({
    req(input$DC_to_be_saved_script_name)
    tags$iframe(style="height:600px; width:100%", src= paste0(substr(basename(input$DC_to_be_saved_script_name), 1,nchar(basename(input$DC_to_be_saved_script_name))-3), "pdf"))
  })




  observeEvent(input$Plot_create_pdf,{
    req(rv$result_chosen, input$Plot_timeseries_result_type)
    append_result_to_pdf_and_knit(rv$result_chosen, input$Plot_timeseries_result_type)
    print("done")
    output$Plot_pdf <- renderUI({
      req(rv$result_chosen)
      tags$iframe(style="height:600px; width:100%", src= paste0(substr(basename(rv$result_chosen), 1,nchar(basename(rv$result_chosen))-3), "pdf"))
      # return(paste('<iframe style="height:600px; width:100%" src="', file.path(script_base_dir, paste0(substr(basename(rv$result_chosen), 1,nchar(basename(rv$result_chosen))-3), "pdf")), '"></iframe>', sep = ""))
      # return(paste('<iframe style="height:600px; width:100%" src="', "https://asterius.hampshire.edu/s/afd81b2933ea5d1a296e3/files/GitHub/shinyNDTr/scripts/rmd.pdf", '"></iframe>', sep = ""))
    })

  })

  output$Plot_show_chosen_result = renderText({
    # temp_text = "Chose result"
    # rv$result_cur_dir_name <- parseDirPath(c(wd=eval(getwd())),input$Plot_chosen_result)
    if(is.na(rv$result_chosen)){
      "No file chosen yet"
    } else{
      basename(rv$result_chosen)

    }
  })


  output$Plot_timeseries = renderPlot({
    req(rv$result_data)
    # print(input$Plot_timeseries_result_type)
    length(rv$result_data)
    typeof(rv$result_data)

    temp_result <- rv$result_data[[input$Plot_timeseries_result_type]]

    # get the mean over CV splits

    temp_mean_results <- colMeans(temp_result)

    temp_time_bin_names <- NDTr::get_center_bin_time(dimnames(temp_result)[[3]])

    # plot(temp_time_bin_names, diag(temp_mean_results), type = "o", xlab = "Time (ms)", ylab = "Classification Accuracy")
    # abline(v = 0)

    temp_result_df <- data.frame(time = temp_time_bin_names, results = diag(temp_mean_results))


    if (input$Plot_timeseries_result_type == "zero_one_loss_results") {
      ylabel <- "Classification accuracy"
    } else if (input$Plot_timeseries_result_type == "rank_results") {
      ylabel <- "Normalized rank"
    } else if (input$Plot_timeseries_result_type == "decision_value_results") {
      ylabel <- "Decision values"
    }


    temp_result_df %>%
      ggplot(aes(x = time, y = results)) +
      geom_line() +
      xlab("Time (ms)") +
      ylab(ylabel) +
      theme_bw()



  })



  output$Plot_tct = renderPlot({
    req(rv$result_data)
    temp_result <- rv$result_data[[input$Plot_tct_result_type]]

    # get the mean over CV splits

    temp_mean_results <- colMeans(temp_result)

    temp_time_bin_names <- NDTr::get_center_bin_time(dimnames(temp_result)[[3]])

    image.plot(temp_time_bin_names, temp_time_bin_names, temp_mean_results,

               legend.lab = "Classification Accuracy", xlab = "Test time (ms)",

               ylab = "Train time (ms)")

    abline(v = 0)

  })

}






