/**
 * MP Modal - Simple modal functionality to replace Bootstrap modals
 * Provides basic show/hide functionality for modals
 */

class MPModal {
  constructor(element) {
    this.element = typeof element === 'string' ? document.querySelector(element) : element;
    this.backdrop = null;
    this.isShown = false;
    
    if (this.element) {
      this.init();
    }
  }
  
  init() {
    // Add event listeners for close buttons
    const closeButtons = this.element.querySelectorAll('[data-mp-dismiss="modal"]');
    closeButtons.forEach(button => {
      button.addEventListener('click', () => this.hide());
    });
    
    // Close modal when clicking on backdrop
    this.element.addEventListener('click', (e) => {
      if (e.target === this.element) {
        this.hide();
      }
    });
    
    // Close modal with Escape key
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.isShown) {
        this.hide();
      }
    });
  }
  
  show() {
    if (this.isShown) return;
    
    this.isShown = true;
    
    // Add show class
    this.element.classList.add('mp-show');
    
    // Prevent body scroll
    document.body.style.overflow = 'hidden';
    
    // Focus on modal
    this.element.focus();
    
    // Trigger custom event
    this.element.dispatchEvent(new CustomEvent('mp.modal.show'));
  }
  
  hide() {
    if (!this.isShown) return;
    
    this.isShown = false;
    
    // Remove show class
    this.element.classList.remove('mp-show');
    
    // Restore body scroll
    document.body.style.overflow = '';
    
    // Trigger custom event
    this.element.dispatchEvent(new CustomEvent('mp.modal.hide'));
  }
  
  toggle() {
    if (this.isShown) {
      this.hide();
    } else {
      this.show();
    }
  }
}

// Global function to create new modal instances (similar to Bootstrap API)
window.MPModal = MPModal;

// Auto-initialize modals with data attributes
document.addEventListener('DOMContentLoaded', function() {
  const modalTriggers = document.querySelectorAll('[data-mp-toggle="modal"]');
  
  modalTriggers.forEach(trigger => {
    const targetSelector = trigger.getAttribute('data-mp-target');
    const targetElement = document.querySelector(targetSelector);
    
    if (targetElement) {
      const modal = new MPModal(targetElement);
      
      trigger.addEventListener('click', function(e) {
        e.preventDefault();
        modal.show();
      });
    }
  });
});
