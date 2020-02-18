datatable_setting <- function(df) {
  DT::datatable(
    df,
    extensions = c('Buttons', 'Scroller'),
    options = list(
      search = list(regex = TRUE),
      searchHighlight = TRUE,
      pageLength = 25,
      dom = 'Bfrtip',
      buttons = c('copy', 'csv', 'excel', 'print'),
      deferRender = TRUE,
      scrollY = 200,
      scroller = TRUE
    ), 
    filter = 'top'
  )
}

# Check if required packages are installed ----
packages <- c("cowplot", "readr", "ggplot2", "dplyr", "lavaan", "smooth", "Hmisc")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}

# Load packages ----
library(ggplot2)

# Defining the geom_flat_violin function ----
# Note: the below code modifies the
# existing github page by removing a parenthesis in line 50

"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}

geom_flat_violin <- function(mapping = NULL, data = NULL, stat = "ydensity",
                             position = "dodge", trim = TRUE, scale = "area",
                             show.legend = NA, inherit.aes = TRUE, ...) {
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomFlatViolin,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      trim = trim,
      scale = scale,
      ...
    )
  )
}

#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomFlatViolin <-
  ggproto("GeomFlatViolin", Geom,
          setup_data = function(data, params) {
            data$width <- data$width %||%
              params$width %||% (resolution(data$x, FALSE) * 0.9)
            
            # ymin, ymax, xmin, and xmax define the bounding rectangle for each group
            data %>%
              group_by(group) %>%
              mutate(
                ymin = min(y),
                ymax = max(y),
                xmin = x,
                xmax = x + width / 2
              )
          },
          
          draw_group = function(data, panel_scales, coord) {
            # Find the points for the line to go all the way around
            data <- transform(data,
                              xminv = x,
                              xmaxv = x + violinwidth * (xmax - x)
            )
            
            # Make sure it's sorted properly to draw the outline
            newdata <- rbind(
              plyr::arrange(transform(data, x = xminv), y),
              plyr::arrange(transform(data, x = xmaxv), -y)
            )
            
            # Close the polygon: set first and last point the same
            # Needed for coord_polar and such
            newdata <- rbind(newdata, newdata[1, ])
            
            ggplot2:::ggname("geom_flat_violin", GeomPolygon$draw_panel(newdata, panel_scales, coord))
          },
          
          draw_key = draw_key_polygon,
          
          default_aes = aes(
            weight = 1, colour = "grey20", fill = "white", size = 0.5,
            alpha = NA, linetype = "solid"
          ),
          
          required_aes = c("x", "y")
  )


df_select_n <- function(df) {
  df <- df %>% 
    select(session, type, sequence_BIDS, relevant) %>% 
    group_by_all() %>% 
    count() %>% 
    ungroup()  
   # spread(. ,session, value = n)
  return(df)
}

df_select_n_group <- function(df) {
  df <- df %>% 
    select(session, type, sequence_BIDS, group_BIDS, PatientSex, relevant) %>%
    filter(relevant == 1) %>%
    group_by_all() %>% 
    count() %>% 
    ungroup() 
  return(df)
}

df_select_patient_info <- function(df){
  df2 <- df %>% mutate(group_BIDS = "all") 
  df3 <- df2 %>% mutate(PatientSex = "all")
  df4 <- df %>% mutate(PatientSex = "all")

    df <- df %>%
    rbind(df2) %>%
    rbind(df3) %>%
    rbind(df4) %>%
    select(subject, session, group_BIDS, PatientSex, PatientWeight, PatientBirthDate, AcquisitionDateTime) %>%
    mutate(AcquisitionDateTime = as.Date(AcquisitionDateTime),
           Age = time_length(difftime(AcquisitionDateTime, PatientBirthDate), "years") %>% round(digits = 2)) %>% 
    unique()
  return(df)
}

df_select_patient_info2 <- function(df){

  df <- df %>%
    select(subject, session, group_BIDS, PatientSex, PatientWeight, PatientBirthDate, AcquisitionDateTime) %>%
    mutate(AcquisitionDateTime = as.Date(AcquisitionDateTime),
           Age = time_length(difftime(AcquisitionDateTime, PatientBirthDate), "years") %>% round(digits = 2)) %>% 
    unique()
  return(df)
}

plot_bar <- function(df){
  p <- df %>% 
    # filter(relevant == 1) %>% 
    ggplot(aes(x = sequence_BIDS, y = n, fill = session)) + 
    geom_bar(position="dodge", stat = "identity") +
    facet_wrap(. ~ desc(relevant), nrow = 2, scales = "free", labeller = label_both) +
    theme_minimal() +
    ggtitle("Barplots of n=Sequence, split by session-id and relevance") +  
    theme(legend.position="none", axis.text.x = element_text(angle = 45, hjust = 1))
  
  
  ggplotly(p) %>% layout(margin = list(l = 100, r = 20, b = 50, t = 100))
}


show_settings <- function(df) {
  df <- df %>%
    select(sequence_BIDS, 
           AcquisitionMatrixPE, ReconMatrixPE, PercentPhaseFOV, PhaseEncodingSteps,
           SliceThickness,
           SpacingBetweenSlices,
           EchoTime, EchoTrainLength, RepetitionTime,
           InversionTime,
           FlipAngle, PartialFourier, PhaseEncodingAxis,
           InPlanePhaseEncodingDirectionDICOM, MRAcquisitionType, NumberOfAverages
           ) %>%
    mutate_if(is.numeric, round, digits = 2) %>%
    group_by_all() %>%
    count() %>%
    ungroup() %>%
    select(sequence_BIDS, n, everything())
  return(df)
}
