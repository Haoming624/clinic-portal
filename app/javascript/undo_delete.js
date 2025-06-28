// Undo Delete Functionality
document.addEventListener('DOMContentLoaded', function() {
  console.log('Undo delete script loaded');
  checkForUndoLinks();
  setupUndoLinkHandlers();
  checkForDeletedPatient();
});

document.addEventListener('turbo:load', function() {
  console.log('Turbo load - checking for undo links');
  checkForUndoLinks();
  setupUndoLinkHandlers();
  checkForDeletedPatient();
});

// Also check after a short delay to catch any late-rendered messages
document.addEventListener('turbo:render', function() {
  console.log('Turbo render - checking for undo links');
  setTimeout(function() {
    checkForUndoLinks();
    checkForDeletedPatient();
  }, 100);
});

function checkForUndoLinks() {
  // Check if there's a delete success message with undo link
  const deleteMessages = document.querySelectorAll('.alert-success');
  console.log('Found', deleteMessages.length, 'success messages');
  
  deleteMessages.forEach(function(message) {
    console.log('Checking message:', message.textContent);
    const undoLink = message.querySelector('a[data-method="patch"]');
    if (undoLink) {
      console.log('Found undo link:', undoLink.href);
      // Create a better undo notification
      createUndoNotification(undoLink);
      
      // Remove the original message
      message.remove();
    } else {
      console.log('No undo link found in message');
    }
  });
}

function checkForDeletedPatient() {
  // Check if there's a success message about patient deletion
  const deleteMessages = document.querySelectorAll('.alert-success');
  console.log('Checking for deleted patient messages:', deleteMessages.length);
  
  deleteMessages.forEach(function(message) {
    console.log('Message content:', message.textContent);
    if (message.textContent.includes('was successfully deleted')) {
      console.log('Found delete success message, creating undo notification');
      
      // Use the restore_last endpoint
      const restoreUrl = '/patients/restore_last';
      
      // Create a temporary link object for the undo notification
      const tempLink = {
        href: restoreUrl,
        getAttribute: function(name) {
          if (name === 'data-patient-id') {
            return 'last'; // We'll handle this in the controller
          }
          return null;
        }
      };
      
      console.log('Creating undo notification with URL:', restoreUrl);
      createUndoNotification(tempLink);
      
      // Remove the original message
      message.remove();
    }
  });
}

function setupUndoLinkHandlers() {
  // Handle direct clicks on undo links to prevent GET requests
  document.addEventListener('click', function(e) {
    if (e.target.matches('a[data-method="patch"]') && e.target.href.includes('/restore')) {
      e.preventDefault();
      console.log('Preventing direct click on undo link');
      
      const undoLink = e.target;
      if (confirm('Restore this patient?')) {
        console.log('Creating restore form for:', undoLink.href);
        
        // Create form and submit
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = undoLink.href;
        
        const methodInput = document.createElement('input');
        methodInput.type = 'hidden';
        methodInput.name = '_method';
        methodInput.value = 'PATCH';
        
        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = 'authenticity_token';
        csrfInput.value = document.querySelector('meta[name="csrf-token"]').content;
        
        form.appendChild(methodInput);
        form.appendChild(csrfInput);
        document.body.appendChild(form);
        
        console.log('Submitting restore form');
        form.submit();
      }
    }
  });
}

// Make createUndoNotification globally accessible
window.createUndoNotification = function(undoLink) {
  console.log('Creating undo notification for:', undoLink.href);
  
  // Create toast notification
  const toast = document.createElement('div');
  toast.className = 'toast show position-fixed';
  toast.style.cssText = `
    top: 20px;
    right: 20px;
    z-index: 9999;
    background: #28a745;
    color: white;
    border: none;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    min-width: 300px;
  `;
  
  const toastBody = document.createElement('div');
  toastBody.className = 'toast-body d-flex justify-content-between align-items-center';
  
  const message = document.createElement('span');
  message.textContent = 'Patient deleted successfully';
  
  const undoButton = document.createElement('button');
  undoButton.className = 'btn btn-sm btn-outline-light ms-3';
  undoButton.textContent = 'Undo';
  undoButton.style.cssText = `
    border-color: white;
    color: white;
    background: transparent;
  `;
  
  // Add hover effect
  undoButton.addEventListener('mouseenter', function() {
    this.style.background = 'white';
    this.style.color = '#28a745';
  });
  
  undoButton.addEventListener('mouseleave', function() {
    this.style.background = 'transparent';
    this.style.color = 'white';
  });
  
  // Handle undo click
  undoButton.addEventListener('click', function() {
    console.log('Undo button clicked');
    if (confirm('Restore this patient?')) {
      console.log('Creating restore form for:', undoLink.href);
      
      // Create form and submit
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = undoLink.href;
      
      const methodInput = document.createElement('input');
      methodInput.type = 'hidden';
      methodInput.name = '_method';
      methodInput.value = 'PATCH';
      
      const csrfInput = document.createElement('input');
      csrfInput.type = 'hidden';
      csrfInput.name = 'authenticity_token';
      csrfInput.value = document.querySelector('meta[name="csrf-token"]').content;
      
      form.appendChild(methodInput);
      form.appendChild(csrfInput);
      document.body.appendChild(form);
      
      console.log('Submitting restore form to:', undoLink.href);
      console.log('Form data:', {
        method: 'PATCH',
        action: undoLink.href,
        csrf_token: csrfInput.value
      });
      
      form.submit();
    }
  });
  
  toastBody.appendChild(message);
  toastBody.appendChild(undoButton);
  toast.appendChild(toastBody);
  
  // Add to page
  document.body.appendChild(toast);
  console.log('Toast notification added to page');
  
  // Auto-remove after 10 seconds
  setTimeout(function() {
    if (toast.parentNode) {
      toast.style.opacity = '0';
      toast.style.transition = 'opacity 0.5s ease';
      setTimeout(function() {
        if (toast.parentNode) {
          toast.parentNode.removeChild(toast);
        }
      }, 500);
    }
  }, 10000);
  
  // Add manual close button
  const closeButton = document.createElement('button');
  closeButton.className = 'btn-close btn-close-white ms-2';
  closeButton.style.cssText = 'filter: invert(1);';
  closeButton.addEventListener('click', function() {
    if (toast.parentNode) {
      toast.parentNode.removeChild(toast);
    }
  });
  
  toastBody.appendChild(closeButton);
};

// Handle AJAX delete requests
document.addEventListener('click', function(e) {
  if (e.target.matches('[data-confirm*="delete"]') || e.target.closest('[data-confirm*="delete"]')) {
    const link = e.target.matches('[data-confirm*="delete"]') ? e.target : e.target.closest('[data-confirm*="delete"]');
    
    if (confirm(link.dataset.confirm || 'Are you sure?')) {
      // Store the link for potential undo
      sessionStorage.setItem('lastDeleteLink', link.href);
      sessionStorage.setItem('lastDeleteTime', Date.now());
    }
  }
}); 