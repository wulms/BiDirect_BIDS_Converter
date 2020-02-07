# add BIDS metadata (dataset.json, CHANGES, README)
#' Title
#'
#' @return
#' @export
#'
#' @examples
add_BIDS_metadata <- function(){
  add_participants_tsv <- function(){
    # Select columns from json dataframe, mutate relevant columns
    patient_tsv <- diagnostics$json_data %>% 
      select(subject, session, group_BIDS, PatientBirthDate, AcquisitionDateTime, PatientSex, PatientWeight) %>%
      rename(participant_id = subject,
             group_id = group_BIDS,
             birthdate = PatientBirthDate,
             acquisitiondate = AcquisitionDateTime,
             sex = PatientSex,
             weight = PatientWeight) %>%
      mutate(acquisitiondate = as.Date(acquisitiondate),
             age = time_length(difftime(acquisitiondate, birthdate), "years") %>% round(digits = 2)) %>%
      unique()
    # Write participants.tvs file
    write_tsv(patient_tsv,
              paste0(variables_environment$directories$needed$bids, "/participants.tsv"))
    writeLines(participants, 
               paste0(variables_environment$directories$needed$bids, "/participants.json"))
    
  }
  add_participants_tsv()
  # add CHANGES, README, dataset_description 
  
  write_metadata_bids <- function(txt_input, file_path){
    if (file.exists(file_path) == 0) {
      writeLines(txt_input, file_path)
    }
  }
  
  write_metadata_bids(CHANGES, variables_environment$files$bids$bids_changes_txt)
  write_metadata_bids(README,  variables_environment$files$bids$bids_readme_txt)
  write_metadata_bids(dataset_description, variables_environment$files$bids$bids_dataset_json)
  
  create_taskname_metadata <- function(json_df){
    taskname_df <- json_df %>% as_tibble() %>%
      filter(type == "func") %>% 
      select(BIDS_sequence_ID, RepetitionTime) %>%
      unique() %>%
      mutate(string = paste0('{\n\t"TaskName": "', BIDS_sequence_ID, '",\n\t"RepetitionTime": ', RepetitionTime, '\n}'),
             filename = paste0(variables_environment$directories$needed$bids, "/", BIDS_sequence_ID, ".json"))
    return(taskname_df)
  }
  
  taskname_jsons <- create_taskname_metadata(diagnostics$json_data)
  for (i in 1:nrow(taskname_jsons))
    write_metadata_bids(taskname_jsons$string[i],
                        taskname_jsons$filename[i])
  
}