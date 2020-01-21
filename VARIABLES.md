# VARIABLES 

## user variables

## scanned variables

DICOM_folders <- containing list of all folders, that contain _/DICOMS_
JSON_files <- containing list of all JSON files in _/NII_headers_

## transformed variables

DICOMS_mapping <- dataframe; based on _DICOM_folders_ containing DICOM_input, your_session_name, your_subject_name, group_id, BIDS_session, BIDS_subject, NII_temp_output
JSON_mapping <- dataframe; based on _JSON_files_ containing JSON_input, your_session_name, your_subject_name, group_id, your_sequence_name, BIDS_session, BIDS_subject, BIDS_sequence, BIDS_output
JSON_headers <- dataframe(empty); _needs_updates_; extracted values off all JSON headers (column names) - really important for joining the data!
JSON_metainfo <- dataframe; _needs_updates_; contains all information from each _JSON_files_ joined to the _JSON_headers_.

## saved variables (from .csv/.tsv)
DICOMS_csv <- containing the already processed DICOMS (based on DICOMS_mapping)
JSON_csv <- containing the already processed JSON (based on JSON_mapping), also contains the headers!
JSON_headers_csv <- empty version of JSON_csv

## saved variables with user interaction
user_settings_sessions_csv <- dataframe; _needs_updates_; Codebook: your_session_id, BIDS_session_id
user_settings_sequences_csv <- dataframe; _needs_updates_; Codebook: your_sequence_id, BIDS_sequence_id
user_settings_subjects_csv <- regex_subject_id, regex_group_id, regex_patterns_to_remove

## anti_joined variables 

DICOMS_diff <- DICOM_folders - DICOMS_csv ones! -> crucial for converting new dicoms 2 nii 
JSON_diff <- JSON_files - JSON_csv
JSON_headers_diff <- JSON_headers - JSON_headers_csv

user_session_diff <- unique_sessions - unique_sessions_csv
user_sequence_diff <- unique_sequences - unique_sessions_csv

#### or

DICOMS_done.txt <- writes done.txt to the processed folders, compares, if the file exists in the folder, skips then the participant.
JSON needs recalculation each time, due to possible differences in columns of the JSON_header. We want to include all columns and not select some columns and ignore others.