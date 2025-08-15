# How to Use Feedback Reports

Feedback Reports allow instructors to generate and send automated progress reports to students based on their Canvas assignments, attendance records, and instructor impressions.

## Prerequisites

Before using Feedback Reports, ensure you have:

1. Uploaded at least one Canvas Gradebook Snapshot for your cohort
2. Students with Discord IDs set up in their profiles (for sending reports)
3. Some recorded attendances and/or impressions (optional, but recommended)

## Generating Feedback Reports

### Step 1: Access the Feedback Reports Page

1. Navigate to your cohort dashboard
2. Click on the "Feedback Reports" tab in the navigation menu

### Step 2: Generate Batch Reports

1. Click the "Generate Feedback Reports" button at the top of the page
2. In the modal that appears:
   - Select a Canvas Gradebook Snapshot from the dropdown
   - Choose a date range for the report (default is the last two weeks)
   - Select which assignments to include (use "Select All" or "Clear All" buttons as needed)
3. Click "Generate Reports" to create reports for all students in the cohort

### Step 3: Review Generated Reports

After generating reports, you'll be redirected to the Feedback Reports index page where you can see:

- A list of all generated reports
- Student names
- Date ranges covered
- Creation dates
- Status indicators (Pending, Sent, Failed)
- Action buttons for each report

## Sending Reports to Students

### Individual Reports

To send an individual report:

1. Find the student's report in the list
2. Click the "Send" button next to the report you want to send
3. Confirm your action when prompted

The report will be sent to the student via Discord DM. The status will update to either:
- **Sent**: Successfully delivered
- **Failed**: Delivery failed (hover over the status to see the error)

### Troubleshooting Failed Reports

If a report fails to send, it's typically because:

1. **Missing Discord ID**: Ensure the student has their Discord ID set in their profile
2. **Discord API Issues**: Check that the Discord bot is running and has proper permissions

## Report Content

Each Feedback Report includes:

1. **Missing Assignments**: Lists assignments not submitted within the selected date range
2. **Impressions**: Shows instructor impressions recorded during the period
3. **Attendance**: Displays attendance records for the selected date range

## Best Practices

- **Regular Reports**: Generate reports on a consistent schedule (weekly or bi-weekly depending on the evolution of the program)
- **Relevant Time Frames**: Choose date ranges that align with your curriculum milestones
- **Review Before Sending**: Check reports before sending them to students and edit as needed

## Advanced Usage

### Customizing Report Messages

If you need to customize a report before sending:

1. Click "View" on the report
2. Click "Edit" to modify the message
3. Make your changes and save
4. Send the updated report
