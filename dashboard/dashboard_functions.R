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
  df <- df %>%
    rbind(df2) %>%
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
    ggtitle("Barplots of n=Sequence, split by session-id and relevance")
  
  
  ggplotly(p) %>% layout(margin = list(l = 100, r = 20, b = 50, t = 100))
}


show_settings <- function(df) {
  df <- df %>%
    select(-filename, 
           -subject, 
           -session, 
           -level, 
           -input_json, 
           -BIDS_json,
           -sequence,
           -BIDS_sequence_ID,
           -SeriesDescription,
           -ProtocolName,
           -InstitutionalDepartmentName,
           -InstitutionName,
           -Manufacturer,
           -ManufacturersModelName,
           -MagneticFieldStrength,
           -Modality,
           -DeviceSerialNumber,
           -SoftwareVersions,
           -StationName) %>%
    select(-AcquisitionNumber,
      -ImageOrientationPatientDICOM,
      -ImageType,
      -ProcedureStepDescription,
      -AccessionNumber,
      -StudyID,
      -StudyInstanceUID,
      -SeriesNumber,
      -SeriesInstanceUID
    ) %>%
    select(
      -AcquisitionDateTime,
      -AcquisitionTime,
      -PatientBirthDate,
      -PatientID,
      -PatientSex,
      -PatientName,
      -PatientWeight,
      -PhilipsRescaleSlope
    ) %>%
    mutate_if(is.numeric, round, digits = 2) %>%
    group_by_all() %>%
    count() %>%
    ungroup() %>%
    select(sequence_BIDS, type, n, group_BIDS, relevant, everything())
  return(df)
}
