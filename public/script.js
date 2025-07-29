class ImageGenerator {
    constructor() {
        this.form = document.getElementById('textForm');
        this.generateBtn = document.getElementById('generateBtn');
        this.resultDiv = document.getElementById('result');
        this.errorDiv = document.getElementById('error');
        this.generatedImage = document.getElementById('generatedImage');
        this.downloadBtn = document.getElementById('downloadBtn');
        this.colorInput = document.getElementById('color');
        this.colorPreview = document.querySelector('.color-preview');
        
        this.init();
    }

    init() {
        this.form.addEventListener('submit', this.handleSubmit.bind(this));
        this.downloadBtn.addEventListener('click', this.handleDownload.bind(this));
        this.colorInput.addEventListener('input', this.updateColorPreview.bind(this));
        
        // Initialize color preview
        this.updateColorPreview();
        
        // Check if template exists
        this.checkTemplate();
    }

    async checkTemplate() {
        try {
            const response = await fetch('/check-template');
            const data = await response.json();
            
            if (data.created) {
                this.showMessage('Template image created successfully!', 'success');
            }
        } catch (error) {
            console.error('Error checking template:', error);
        }
    }

    updateColorPreview() {
        this.colorPreview.style.background = this.colorInput.value;
    }

    async handleSubmit(e) {
        e.preventDefault();
        
        const formData = new FormData(this.form);
        const data = Object.fromEntries(formData.entries());
        
        if (!data.text.trim()) {
            this.showError('Please enter some text');
            return;
        }

        this.setLoading(true);
        this.hideError();

        try {
            const response = await fetch('/generate', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || 'Failed to generate image');
            }

            // Get the image blob
            const blob = await response.blob();
            const imageUrl = URL.createObjectURL(blob);
            
            // Store the blob for download
            this.imageBlob = blob;
            
            // Display the image
            this.generatedImage.src = imageUrl;
            this.showResult();

        } catch (error) {
            console.error('Error:', error);
            this.showError(error.message || 'Failed to generate image');
        } finally {
            this.setLoading(false);
        }
    }

    handleDownload() {
        if (this.imageBlob) {
            const url = URL.createObjectURL(this.imageBlob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `generated-image-${Date.now()}.png`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }
    }

    setLoading(loading) {
        if (loading) {
            this.generateBtn.classList.add('loading');
            this.generateBtn.disabled = true;
        } else {
            this.generateBtn.classList.remove('loading');
            this.generateBtn.disabled = false;
        }
    }

    showResult() {
        this.resultDiv.classList.remove('hidden');
        this.resultDiv.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }

    showError(message) {
        this.errorDiv.textContent = message;
        this.errorDiv.classList.remove('hidden');
        this.errorDiv.scrollIntoView({ behavior: 'smooth' });
    }
    
    showMessage(message, type = 'info') {
        // Create a temporary message element
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${type}`;
        messageDiv.textContent = message;
        messageDiv.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 20px;
            background: ${type === 'success' ? '#10b981' : '#3b82f6'};
            color: white;
            border-radius: 8px;
            font-weight: 500;
            z-index: 1000;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            animation: slideIn 0.3s ease;
        `;
        
        document.body.appendChild(messageDiv);
        
        setTimeout(() => {
            messageDiv.style.animation = 'slideOut 0.3s ease forwards';
            setTimeout(() => {
                document.body.removeChild(messageDiv);
            }, 300);
        }, 3000);
    }

    hideError() {
        this.errorDiv.classList.add('hidden');
    }
}

// Add CSS animations for messages
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

// Initialize the app
document.addEventListener('DOMContentLoaded', () => {
    new ImageGenerator();
});