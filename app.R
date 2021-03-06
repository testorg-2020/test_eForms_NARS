#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
source('global.r')

# Define UI for application that draws a histogram
ui <- fluidPage(
#   theme="style.css",
   shinyjs::useShinyjs(),
   # Application title
   navbarPage("NARS Rapid Data Extraction & Reporting Tool (v. 0.1)",
              tabPanel(span('About',title='How to use this Shiny app'),
                       fluidRow(column(2, imageOutput("narsLogo")),
                                column(6,h2(strong('Tool Overview')), offset=1,
                                       p('The NARS Rapid Data Extraction and Reporting Tool expedites data availability
                                                            to field crews and offers preliminary end-of-day site reports to landowners to
                                         promote survey awareness and continued sampling support.'),
                                       br(),
                                       p('After completing all sampling and sample processing, crews submit data from the app to ',
                                         span(strong('NARS IM.')),'At that point, all of the .JSON files from that site visit
                                                            and collected on that iPad will be attached to an email to NARS IM.
                                                            The crew can copy that email to other
                                                            addresses and later save those .JSON files (and any from other iPads
                                                            used at that site) to a folder containing all of the data collected
                                                            from an individual site visit. This tool parses and compiles the data
                                                            from .JSON files into spreadsheet formats to
                                                            promote data utility and offers and optional site report based on
                                                            field-collected data, such as field parameters and lists of fish
                                                            species collected, to be sent by the team lead to the landowner shortly
                                                            after sampling.'),
                                       br(),
                                       # p('Please direct all questions related to tool troubleshooting and feature requests to
                                       #                      Karen Blocksom (Blocksom.Karen@epa.gov).')
                                       ),
                                column(1)), br(), hr(), br(),
                       fluidRow(column(1), column(10, h3(strong('Instructions')),
                                                  p('After compiling all of the .JSON files for a site visit into a single directory,
                                                  users are ready to extract and organize the data. On the Data Upload and Extraction
                                                  tab, users first select the survey app used to collect the data (NRSA 2018-19,
                                                  NLA 2017, or NCCA 2020), then select the directory where their data is saved
                                                    to upload .JSON files to the app for processing. Once the data is uploaded to
                                                    the app, click the',
                                                  span(strong('Parse data in selected files')), 'button. Then users will have
                                                            the option to save the data as a .zip file containing individual .csv
                                                            files or a single MS Excel spreadsheet containing worksheets of each dataset.',
                                                  span(strong('If data outputs do not look as expected, make sure you have selected the
                                                            correct survey app. Only valid sample types will be processed for each survey,
                                                            so if data are missing, that is a possible reason.'))),
                                                  br(),
                                                  p('After uploading the data, if users want to generate a basic site report for their
                                                            records or to distribute to the landowner, they may navigate to the Landowner
                                                            Report tab and follow the on screen prompts to save an
                                                            autogenerated HTML file based on their input site data.')
                                                  ),
                                column(1))),

              tabPanel(span('Data Upload and Extraction',title="Select data to upload and extract"),

                       sidebarPanel(radioButtons('survey',"Select survey app used (select one):",
                                                 choices = c('NRSA 2018-19' = 'nrsa1819',
                                                             'NLA 2017' = 'nla17',
                                                             'NCCA 2020' = 'ncca20'),
                                                 select = ''),
                                    h4(strong('Instructions')),
                                    p('1) Choose the directory where you have saved all of the .JSON files associated
                                          with a single site visit. A list of all file names within the directory will be
                                          available for preview to the right when they are available to the app.'),
                                    fileInput(inputId='directory', buttonLabel='Browse...',
                                              label='Please select files within a folder, holding down Ctrl key to select multiple files.',
                                              multiple=TRUE, accept=c('json','JSON')),
                                    p('2) Click the Upload button below when you are ready to analyze all data in the selected directory.'),
                                    shinyjs::disabled(actionButton('parseFiles','Parse data in selected files')),
                                    br(), hr(),
                                    p('3) If you want to save the parsed files to the local directory, please click the download
                                          button for the appropriate output file format. The buttons will not be available until
                                          the data is finished processing. Once the buttons are available, you may download data.'),
                                    br(),
                                    p('Note: saving as .csv will download a
                                      .zip of all .csv files. All downloads will be saved to your downloads folder.'),
                                    downloadButton("downloadxlsx","Save Results as .xlsx"),
                                    downloadButton("downloadcsv","Save Results as .csv")),
                       bsTooltip('directory','Select directory containing all files for site visit',trigger='hover'),
                       bsTooltip('parseFiles','Click here to parse and organize data',trigger='hover'),
                       bsTooltip('downloadxlsx','Save data to worksheets in an Excel file.',trigger='hover'),
                       bsTooltip('downloadcsv','Save data to comma-delimited files in a .zip file.',trigger='hover'),
                       mainPanel(
                         h5('Preview files in directory'),
                         tableOutput('preview'))),
              tabPanel(span('Landowner Report', title='Create a basic landowner report'),
                       sidebarPanel(p('This tool creates a basic report in html format based on data collected during a
                                          field visit to a site. It can be saved for crew records or provided to the landowner,
                                          either via email or printed and mailed. At a minimum, the', span(strong('verification form')),
                                      'must be submitted.')),
                       mainPanel(
                         shinyjs::disabled(downloadButton('report','Generate Landowner Report (HTML)'))))))



# Define server logic required to draw a histogram
server <- function(input, output, session) {
  # render stream image
  output$narsLogo <- renderImage({
    filename <- normalizePath(file.path('./www',
                                        paste('NARS_logo_sm.jpg')))

    # Return list containing the filename and alt text
    list(src = filename, alt='NARS logo')
  },
  deleteFile=FALSE)

  observeEvent(input$survey, {
    shinyjs::enable('parseFiles')
  })

  observeEvent(input$parseFiles, {
    shinyjs::enable('report')
  })

  # Reactive Value to store all user data
  userData <- reactiveValues()


  # Bring in user data when they select directory
  # volumes <- getVolumes()
  path1 <- reactive({
    path_list <- as.vector(input$directory$datapath)
  })

  filesInDir <- reactive({
    name_list <- as.vector(input$directory$name)
  })

  # Files in directory preview for UI - This works
  output$preview <- renderTable({
    req(filesInDir())
    filesInDir() },colnames=FALSE)

  # The user data
  observeEvent(input$parseFiles, {
    userData$finalOut <- narsOrganizationShiny(input$survey, as.vector(input$directory$datapath), as.vector(input$directory$name))  })


  # Don't let user click download button if no data available
  observe({ shinyjs::toggleState('downloadxlsx', length(userData$finalOut) != 0  )  })
  observe({ shinyjs::toggleState('downloadcsv', length(userData$finalOut) != 0  )  })


  # Download Excel File
  output$downloadxlsx<- downloadHandler(filename = function() {
    paste(unique(userData$finalOut[[1]][[1]]$UID),
          "summary.xlsx", sep='_')},
    content = function(file) {
      write_xlsx(narsWriteShiny(input$survey, as.vector(input$directory$name), userData$finalOut), path = file)}
  )


  # Download CSV

  output$downloadcsv <- downloadHandler( filename = function() {
    paste(unique(userData$finalOut[[1]][[1]]$UID),
          "csvFiles.zip", sep="_")
  },
  content = function(fname) {
    fs <- c()
     z <- narsWriteShiny(input$survey, as.vector(input$directory$name), userData$finalOut)

    for (i in 1:length(z)) {

      path <- paste0(unique(userData$finalOut[[1]][[1]]$UID), "_",
                     names(z)[[i]], ".csv")
      fs <- c(fs, path)
      write.csv(data.frame(z[[i]]), path, row.names=F)
    }

    zip::zipr(zipfile=fname, files=fs)

    for(i in 1:length(fs)){
      file.remove(fs[i])
    }
  },
  contentType = "application/zip"
  )


  ####--------------------------------------- RMARKDOWN SECTION--------------------------------------------------

  # Send input data to html report

  output$report <- downloadHandler(filename = function(){
    paste(unique(userData$finalOut[[1]][[1]]$UID),
          "LandownerReport.html",sep="_")
    },
    content= function(file){
      switch(input$survey,
             'nrsa1819' = {reportName <- 'nrsaLandownerReport_fromApp.Rmd'},
             'nla17' = {reportName <- 'nlaLandownerReport_fromApp.Rmd'},
             'ncca20' = {reportName <- 'nccaLandownerReport_fromApp.Rmd'}
             )

      switch(input$survey,
             'nrsa1819' = {logoName <- 'NRSA_logo_sm.jpg'},
             'nla17' = {logoName <- 'NLA_logo_sm.jpg'},
             'ncca20' = {logoName <- 'NCCA_logo_sm.jpg'})
      tempReport <- normalizePath(reportName)
      imageToSend1 <- normalizePath(logoName)  # choose image name
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(tempReport, reportName)
      file.copy(imageToSend1, logoName) # same image name

      params <- list(userDataRMD=userData$finalOut)

      rmarkdown::render(tempReport,output_file = file,
                        params=params,envir=new.env(parent = globalenv()))})


#  session$onSessionEnded(function() {
#    stopApp()
#  })

}

# Run the application
# shinyApp(ui = ui, server = server)
shiny::runApp(list(ui = ui, server = server), host="0.0.0.0", port=strtoi(Sys.getenv("PORT")))
