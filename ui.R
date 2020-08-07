ui <- dashboardPage(
  dashboardHeader(title = "shinyNDTr"),
  dashboardSidebar(
    sidebarMenu(
      # menuItem("Home", tabName = "home"),
      menuItem("Binning the raster data", tabName = "bin"),
      menuItem("Population Decoding", tabName = "decode")#,
      # menuItem("Single Neuron Analysis", tabName = "single")

    )),
  dashboardBody(
    tabItems(
      #   tabItem(tabName = "home",
      #           fluidPage(
      #             shinyFiles::shinyFilesButton("home_loaded_state", lLabels$home_loaded_state, "", multiple = FALSE),
      #             uiOutput("home_offer_save_state")
      #           )
      #   ),
      tabItem(tabName = "bin",
              navbarPage(title = "",


                         tabPanel(
                           title = "Specify binning parameters",
                           fluidPage(

                             fluidRow(
                               column(width = 12,
                                      box(width = NULL,
                                          status = "danger",
                                          solidHeader = TRUE,
                                          title = "Choose a directory of raster data files",

                                          shinyFiles::shinyDirButton("bin_chosen_raster", lLabels$bin_chosen_raster, ""),
                                          helpText("Loaded raster data: "),

                                          textOutput("bin_show_chosen_raster")
                                      ),
                                      box(width = 8,


                                          numericInput("bin_bin_width", lLabels$bin_bin_width, value = 10, min = 1),
                                          numericInput("bin_step_size", lLabels$bin_step_size, value = 1, min = 1),
                                          numericInput("bin_start_ind", lLabels$bin_start_ind, value = NULL),
                                          numericInput("bin_end_ind", lLabels$bin_end_ind, value = NULL),
                                          textInput("bin_prefix_of_binned_file_name", lLabels$bin_prefix_of_binned_file_name),
                                          actionButton("bin_bin_data", lLabels$bin_bin_data),
                                          uiOutput("bin_action_error"),
                                          textOutput("bin_show_create_bin_function_run")                                      )



                               )

                             )
                           )
                         ),
                         tabPanel(

                           title = "Plot raster data",
                           fluidPage(
                             fluidRow(
                               column(width = 12,
                                      box(
                                        width = NULL,
                                        # shinyFilesButton('files', label='File select', title='Please select a file', multiple=FALSE),
                                        # checkboxInput("bin_bPlot", lLabels$bin_bPlot),
                                        # conditionalPanel(condition = "input.bin_bPlot",
                                        actionButton("bin_pre_neuron", lLabels$bin_pre_neuron),
                                        actionButton("bin_next_neuron", lLabels$bin_next_neuron),
                                        textOutput("bin_show_raster_cur_file_name"),
                                        dataTableOutput('where')
                                      ),

                                      tabBox(width = NULL,
                                             title = "",
                                             tabPanel(
                                               title = "Raster plot",
                                               # background = "green",
                                               ribbon = TRUE,
                                               title_side = "top right",
                                               # conditionalPanel(condition = "input.bin_bPlot",

                                               plotOutput("bin_raster_plot")
                                             ),
                                             tabPanel(
                                               width = NULL,
                                               title = "PSTH (Peristimulus time histogram)",
                                               # background = "red",
                                               ribbon = TRUE,
                                               title_side = "top right",
                                               # conditionalPanel(condition = "input.bin_bPlot",

                                               plotOutput("bin_PSTH")
                                             )


                                      )
                               )
                             )
                           )
                         ),
                         tabPanel(
                           title = "Upload new raster data",
                           fluidRow(
                             box(width = NULL,
                                 helpText("We only accept .mat and .Rda format !"),
                                 uiOutput("bin_offer_upload_raster"),
                                 uiOutput("bin_offer_create_raster"),
                                 uiOutput("bin_evil_raster"),
                                 textOutput("bin_show_create_raster_function_run")
                             )
                           )
                         )




              )


      ),
      tabItem(tabName = "decode",
              navbarPage(title = "",


                         tabPanel(
                           title = "Run a decoding analysis",
                           fluidPage(



                             fluidRow(
                               column(width = 12,
                                      tabBox(width = 12,

                                             # tabPanel(
                                             #   title = "Upload new binned data",
                                             #   width = NULL,
                                             #   solidHeader = TRUE, status = "primary",
                                             #   uiOutput("DS_offer_upload_bin")
                                             #
                                             # ),
                                             tabPanel(
                                               title = "Data source",
                                               width = NULL,
                                               solidHeader = TRUE,
                                               status = "primary",
                                               box(
                                                 width = NULL,
                                                 title = "Choose a binned data file",
                                                 status = "danger",
                                                 solidHeader = TRUE,
                                                 shinyFiles::shinyFilesButton("DS_chosen_bin", lLabels$DS_chosen_bin, "", multiple = FALSE),
                                                 helpText("Loaded binned data: "),

                                                 textOutput("DS_show_chosen_bin")

                                               ),


                                               selectInput("DS_type", lLabels$DS_type, c("basic_DS","generalization_DS")),



                                               conditionalPanel(condition = "input.DS_type == 'basic_DS'",
                                                                uiOutput("DS_basic_list_of_var_to_decode"),

                                                                checkboxInput("DS_bUse_all_levels", "Use all the levels of this variable?", TRUE)
                                               ),
                                               conditionalPanel(condition = "!input.DS_bUse_all_levels && input.DS_type == 'basic_DS'",
                                                                uiOutput("DS_basic_list_of_levels_to_use")),


                                               conditionalPanel(condition = "input.DS_type == 'generalization_DS'",
                                                                uiOutput("DS_gen_list_of_var_to_decode"),
                                                                uiOutput("DS_gen_list_of_var_to_use"),
                                                                uiOutput("DS_gen_select_num_of_groups"),
                                                                uiOutput("DS_gen_list_of_training_level_groups")#,
                                                                # uiOutput("DS_gen_list_of_testing_level_groups")
                                               )
                                             ),

                                             tabPanel(
                                               title = "Classifier",
                                               width = NULL,
                                               solidHeader = TRUE, status = "primary",
                                               selectInput("CL", "Classifier", all_cl),
                                               box(
                                                 width = NULL,
                                                 title = "Additional parameters (if applicable)",
                                                 conditionalPanel(condition  = "input.CL == 'cl_svm'",
                                                                  selectInput("CL_SVM_kernel",
                                                                              lLabels$CL_SVM_kernel,
                                                                              c("linear", "polynomial", "radial", "sigmoid"),
                                                                              selected = "linear"),
                                                                  numericInput("CL_SVM_cost",
                                                                               lLabels$CL_SVM_cost, # of constraints violation / inverse of regularization constant",
                                                                               1,
                                                                               min = 0
                                                                  ),
                                                                  conditionalPanel(condition ="input.CL_SVM_kernel == 'polynomial'",
                                                                                   numericInput("CL_SVM_degree",
                                                                                                lLabels$CL_SVM_degree,
                                                                                                3,
                                                                                                min = 2,
                                                                                                max  = 10)),


                                                                  conditionalPanel(condition = "input.CL_SVM_kernel == 'radial'|input.CL_SVM_kernel == 'polynomial'",
                                                                                   numericInput("CL_SVM_coef0",
                                                                                                lLabels$CL_SVM_coef0, # Constant in the kernel function",
                                                                                                0)),
                                                                  conditionalPanel(condition = "input.CL_SVM_kernel == 'radial'|input.CL_SVM_kernel == 'polynomial'|input.CL_SVM_kernel == 'sigmoid'",
                                                                                   numericInput("CL_SVM_gamma",
                                                                                                lLabels$CL_SVM_gamma,
                                                                                                NULL)
                                                                  )
                                                 ))

                                             ),
                                             tabPanel(
                                               title = "Feature preprocessors",
                                               width = NULL,
                                               solidHeader = TRUE, status = "primary",

                                               uiOutput("FP_check_fp"),
                                               uiOutput("FP_select_k_features"),
                                               uiOutput("FP_exclude_k_features")


                                             ),
                                             tabPanel(
                                               title = "Cross validator",
                                               width = NULL,
                                               solidHeader = TRUE, status = "primary",
                                               fluidRow(
                                                 column(
                                                   width = 6,
                                                   uiOutput("CV_max_repetition_avail_with_any_site"),
                                                   uiOutput("CV_repeat"),
                                                   uiOutput("CV_split"),
                                                   uiOutput("CV_show_chosen_repetition_info"),
                                                   numericInput("CV_resample", lLabels$CV_resample, value = 20, min = 1),
                                                   checkboxInput("CV_bDiag", lLabels$CV_bDiag,TRUE)
                                                 ),
                                                 column(
                                                   width = 6,
                                                   plotlyOutput("CV_show_level_repetition_info")
                                                 )

                                               )



                                             ),


                                             tabPanel(
                                               title = "Run analysis",
                                               width = NULL,
                                               fluidRow(


                                                 column(
                                                   width = 6,
                                                   box(
                                                     title = "Create a new script",
                                                     width = NULL,
                                                     status = "danger",
                                                     # background = "red",
                                                     solidHeader = TRUE,


                                                     radioButtons("DC_script_mode", lLabels$DC_script_mode, c("R", "R Markdown", "Matlab"), selected = "R"),
                                                     uiOutput("DC_offer_scriptize"),
                                                     # textinput of filename to be saved if not existing and to be saved as if existing;
                                                     # uiOutput("DC_offer_save_displayed_script"),
                                                     # helpText("  or"),
                                                     uiOutput("DC_offer_run_decoding")

                                                     # )
                                                   ) #),


                                                   # tabPanel(
                                                   # title = "",
                                                   # width = NULL,

                                                   # box(
                                                   #   title = "Load an existing script",
                                                   #   width = NULL,
                                                   #   status = "success",
                                                   #   # background = "aqua",
                                                   #   solidHeader = TRUE,
                                                   #   # script will show upon chosen
                                                   #   shinyFiles::shinyFilesButton("DC_chosenscript_name", lLabels$DC_chosenscript_name, "", multiple = FALSE),
                                                   #   helpText("Displayed script: "),
                                                   #
                                                   #   textOutput("DC_show_chosen_script")
                                                   # )

                                                 ),


                                                 column(width = 6,
                                                        box(width = NULL,
                                                            uiOutput("DC_ace")
                                                        )
                                                 )


                                               )
                                             ),

                                             tabPanel("PDF",
                                               #width = NULL,

                                               #helpText("The results will appear below once the code is done running"),
                                               uiOutput("DC_pdf")
                                             )




                                      ))





                             )
                           )

                         ),
                         tabPanel(
                           title = "Plot decoding results",

                           column(width = 12,
                                  #issue cannot make use of the large blank on the right
                                  box(
                                    title = "Choose the result to plot",
                                    width = NULL,
                                    status = "danger",
                                    solidHeader = TRUE,
                                    shinyFiles::shinyFilesButton("Plot_chosen_result", lLabels$Plot_chosen_result, "", multiple = FALSE),
                                    helpText("Loaded result: "),
                                    textOutput("Plot_show_chosen_result")


                                  ),
                                  tabBox(width = NULL,
                                         # title = "Result plot",
                                         tabPanel("Timeseries",
                                                  selectInput("Plot_timeseries_result_type", lLabels$Plot_timeseries_result_type,
                                                              all_result_type),
                                                  plotOutput("Plot_timeseries")
                                         ),
                                         tabPanel("TCT heatmap",
                                                  selectInput("Plot_tct_result_type", lLabels$Plot_TCT_result_type,
                                                              all_result_type),
                                                  plotOutput("Plot_tct")
                                         ),

                                         tabPanel("PDF of script and result",
                                                  actionButton("Plot_create_pdf", lLabels$Plot_create_pdf),
                                                  helpText(""),
                                                  uiOutput("Plot_pdf")
                                         )

                                  )
                           )
                         ),
                         tabPanel(

                           title = "Upload new binned data",
                           width = NULL,
                           box(
                             title = NULL,
                             width = NULL,


                             uiOutput("DS_offer_upload_bin")

                           )
                         )
              )
      )

    )


  )

)
