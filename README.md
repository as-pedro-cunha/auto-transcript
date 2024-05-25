# Auto Transcription

A script made in 2022 to automate the transcription of audio files using Whisper AI.

## Table of Contents
- [Description](#description)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Input File Organization](#input-file-organization)
    - [Example Directory Structure](#example-directory-structure)
- [Usage](#usage)
- [Directory Structure](#directory-structure)

## Description

Auto Transcription is a bash script designed to automate the transcription of audio files using Whisper AI. The script processes audio files, converts them to a standard format, and generates transcriptions that is added to the id3v2 tag and also saved as txt in a structured manner.

## Features

- Automated transcription of audio files using Whisper AI.
- Conversion of audio files to a standard format (320kbps MP3).
- Organization of output files in a structured directory.
- Logging of processing details.
- Removal of special characters and normalization of file names.

## Prerequisites

- Bash
- Python 3
- ffmpeg
- id3v2
- Whisper AI model

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/your_username/auto_transcription.git
    cd auto_transcription
    ```

2. Install the required dependencies:
    ```bash
    sudo apt-get install ffmpeg id3v2
    pip install openai-whisper
    ```

3. Ensure the `config.xml` file is correctly set up with the input and output paths:
    ```xml
    <general_params>
        input_path=/path/to/your/input
        output_path=/path/to/your/output
    </general_params>
    ```

4. Ensure the right model is selected in `tools/whisper_fun.py`:
    ```python
    model = whisper.load_model("large-v3")
    ```

## Input File Organization

To ensure the `run.sh` script processes your audio files correctly, you need to organize your input files in a specific directory structure. Follow these guidelines:

1. **Input Directory Structure**:
    - The input directory should be specified in the `config.xml` file under the `<input_path>` tag.
    - Inside the input directory, create subdirectories for each person. Each person's directory should contain subdirectories for different events.

2. **Event Directory Naming**:
    - Each event directory should be named in the format `yyyy_mm_dd_eventName`, where `yyyy` is the year, `mm` is the month, and `dd` is the day of the event.
    - Example: `2024_05_24_BirthdayParty`.

3. **Audio Files**:
    - Place the audio files (in `.mp3` format) inside the respective event directories.
    - Ensure that the audio files are named appropriately, as the script will process and rename them.

### Example Directory Structure

```plaintext
/media/pedro/Arquivos/acervos/input
├── Person1
│   ├── 2024_05_24_BirthdayParty
│   │   ├── track1.mp3
│   │   ├── track2.mp3
│   └── 2024_06_15_Conference
│       ├── track1.mp3
│       ├── track2.mp3
├── Person2
│   ├── 2024_07_10_Wedding
│   │   ├── track1.mp3
│   │   ├── track2.mp3
```

## Usage

1. Place your audio files in the input directory specified in `config.xml`.
2. Run the script:
    ```bash
    ./run.sh
    ```

The script will process the audio files, generate transcriptions, and save the output in the specified output directory.

## Directory Structure

```plaintext
bash/auto_transcription
├── config
│   └── config.xml
├── logs
├── run.sh
└── tools
    ├── aux_functions.sh
    ├── gather_txt.sh
    └── whisper_fun.py
```