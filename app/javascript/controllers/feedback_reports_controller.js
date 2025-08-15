import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "snapshotSelect", "assignmentList", "selectAllBtn", "clearAllBtn", "generateBtn"]
  static values = { cohortId: String }

  connect() {
    this.snapshotSelectTarget.addEventListener('change', this.handleSnapshotChange.bind(this))
    this.selectAllBtnTarget.addEventListener('click', this.handleSelectAll.bind(this))
    this.clearAllBtnTarget.addEventListener('click', this.handleClearAll.bind(this))
    this.formTarget.addEventListener('submit', this.handleSubmit.bind(this))
  }

  async handleSnapshotChange(event) {
    const snapshotId = event.target.value
    if (snapshotId) {
      try {
        const response = await fetch(`/cohorts/${this.cohortIdValue}/canvas_gradebook_snapshots/${snapshotId}/assignments`)
        const assignments = await response.json()
        
        this.assignmentListTarget.innerHTML = assignments.map(assignment => `
          <div class="form-check">
            <input type="checkbox" name="assignments[]" value="${assignment.id}" class="form-check-input assignment-checkbox" id="assignment-${assignment.id}" checked>
            <label for="assignment-${assignment.id}" class="form-check-label">${assignment.name}</label>
          </div>
        `).join('')
      } catch (error) {
        console.error('Error fetching assignments:', error)
      }
    }
  }

  handleSelectAll(event) {
    event.preventDefault()
    this.assignmentListTarget.querySelectorAll('.assignment-checkbox').forEach(cb => cb.checked = true)
  }

  handleClearAll(event) {
    event.preventDefault()
    this.assignmentListTarget.querySelectorAll('.assignment-checkbox').forEach(cb => cb.checked = false)
  }

  handleSubmit(event) {
    event.preventDefault()
    
    const snapshotId = this.snapshotSelectTarget.value
    const startDate = this.formTarget.querySelector('#start_date').value
    const endDate = this.formTarget.querySelector('#end_date').value
    const selectedAssignments = Array.from(this.assignmentListTarget.querySelectorAll('.assignment-checkbox')).filter(cb => cb.checked)
    
    if (!snapshotId) {
      alert('Please select a Canvas Gradebook Snapshot.')
      return
    }
    
    if (!startDate || !endDate) {
      alert('Please select start and end dates.')
      return
    }
    
    if (selectedAssignments.length === 0) {
      alert('Please select at least one assignment.')
      return
    }
    
    // Show loading state
    this.generateBtnTarget.disabled = true
    this.generateBtnTarget.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Generating...'
    
    // Submit form
    this.formTarget.submit()
  }
} 