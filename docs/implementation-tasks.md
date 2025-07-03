# Implementation Tasks for mangadex-downloader-ps

## Completed Stories
- **Documentation Update** - Updated README.md to properly document all current features, parameters, usage examples, and project roadmap (July 2, 2025)

## In Progress Stories
- None yet

## Planned Stories

### Story 01: Pagination Support
- [ ] Analyze MangaDex API pagination requirements
- [ ] Update scripts to handle paginated API responses
- [ ] Test with large manga series
- [ ] Update documentation with usage examples

### Story 02: Advanced Filtering
- [ ] Research available filtering options in MangaDex API
- [ ] Add parameters for group, status, and tags to scripts
- [ ] Implement filtering logic
- [ ] Test filtering with various scenarios
- [ ] Document filtering options

### Story 03: Improved Error Handling & Logging
- [ ] Review current error handling in scripts
- [ ] Add structured logging (to file and console)
- [ ] Improve error messages and handling of API failures
- [ ] Add log rotation or cleanup
- [ ] Update documentation with troubleshooting tips

### Story 04: Unit/Integration Tests
- [ ] Identify testable script components
- [ ] Set up a testing framework for PowerShell scripts
- [ ] Write unit tests for core functions
- [ ] Write integration tests for end-to-end scenarios
- [ ] Document how to run tests

### Story 05: GUI Front-End
- [ ] Choose a technology for the GUI (e.g., PowerShell WPF, Electron, etc.)
- [ ] Design basic UI for inputting manga URL, language, and options
- [ ] Integrate scripts with GUI actions
- [ ] Test GUI usability
- [ ] Document GUI usage

### Story 06: Download Progress Bar
- [ ] Research progress bar options for PowerShell
- [ ] Integrate progress reporting into download scripts
- [ ] Display download speed and estimated time remaining
- [ ] Test with large downloads
- [ ] Update documentation

### Story 07: Incremental Updates
- [ ] Design a mechanism to track downloaded chapters
- [ ] Add option to download only new/updated chapters
- [ ] Test incremental update logic
- [ ] Document incremental update feature

### Story 08: Export to CBZ/PDF
- [ ] Research PowerShell libraries/tools for CBZ/PDF creation
- [ ] Add export options to scripts
- [ ] Implement CBZ/PDF export logic
- [ ] Test export with various manga
- [ ] Document export feature

### Story 09: Multi-language/Group Support
- [ ] Add support for multiple language/group selection
- [ ] Update scripts to handle multiple downloads in parallel or sequence
- [ ] Test with different combinations
- [ ] Document multi-language/group usage

### Story 10: Scheduling/Automation
- [ ] Research scheduling options (Task Scheduler, cron, etc.)
- [ ] Add scheduling/automation scripts or instructions
- [ ] Test scheduled downloads
- [ ] Document scheduling/automation
