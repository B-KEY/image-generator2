const express = require('express');
const sharp = require('sharp');
const path = require('path');
const fs = require('fs');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 9000;

// Store template image in memory
let templateBuffer = null;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// Escape XML special characters in user input to avoid SVG parse errors
function escapeXml(unsafe) {
  return unsafe.replace(/[<>&'"]/g, (c) => {
    switch (c) {
      case '<': return '&lt;';
      case '>': return '&gt;';
      case '&': return '&amp;';
      case '\'': return '&apos;';
      case '"': return '&quot;';
    }
  });
}

// Function to wrap text into lines of maxWidth chars approx.
function wrapText(text, maxWidth = 40) {
  const words = text.split(' ');
  const lines = [];
  let currentLine = '';

  for (const word of words) {
    const testLine = currentLine ? `${currentLine} ${word}` : word;
    if (testLine.length <= maxWidth) {
      currentLine = testLine;
    } else {
      if (currentLine) {
        lines.push(currentLine);
        currentLine = word;
      } else {
        lines.push(word);
      }
    }
  }
  
  if (currentLine) {
    lines.push(currentLine);
  }
  
  return lines;
}

// Create SVG with embedded text (using Arial/sans-serif for compatibility)
function createTextSVG(text, options = {}) {
  const {
    fontSize = 48,
    color = '#000000',
    position = 'middle',
    align = 'center',
    width = 800,
    height = 600
  } = options;

  const lines = wrapText(text, Math.floor(width / (fontSize * 0.6)));
  const lineHeight = fontSize * 1.2;
  const totalTextHeight = lines.length * lineHeight;

  let startY;
  switch (position) {
    case 'top':
      startY = fontSize + 50;
      break;
    case 'bottom':
      startY = height - totalTextHeight - 50;
      break;
    default: // middle
      startY = (height - totalTextHeight) / 2 + fontSize;
  }

  let textAnchor;
  switch (align) {
    case 'left':
      textAnchor = 'start';
      break;
    case 'right':
      textAnchor = 'end';
      break;
    default: // center
      textAnchor = 'middle';
  }

  const textElements = lines.map((line, index) => {
    const y = startY + (index * lineHeight);
    return `<text x="${width / 2}" y="${y}" text-anchor="${textAnchor}" fill="${color}" font-size="${fontSize}" font-family="Arial, sans-serif" font-weight="bold">${escapeXml(line)}</text>`;
  }).join('\n    ');

  return `<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
  ${textElements}
</svg>`;
}

// Initialize template buffer
app.get('/check-template', async (req, res) => {
  if (!templateBuffer) {
    try {
      const templatePath = path.join(__dirname, 'public', 'template.png');
      
      if (fs.existsSync(templatePath)) {
        templateBuffer = await fs.promises.readFile(templatePath);
        await sharp(templateBuffer).metadata();
        res.json({ exists: true, created: false });
      } else {
        templateBuffer = await sharp({
          create: {
            width: 800,
            height: 600,
            channels: 4,
            background: { r: 99, g: 102, b: 241, alpha: 1 }
          }
        })
        .png()
        .toBuffer();
        
        res.json({ exists: true, created: true });
      }
    } catch (error) {
      console.error('Error loading template:', error);
      res.status(500).json({ error: 'Could not create template' });
    }
  } else {
    res.json({ exists: true, created: false });
  }
});

// Generate image endpoint
app.post('/generate', async (req, res) => {
  try {
    const { 
      text, 
      fontSize = 48, 
      color = '#FFFFFF', 
      position = 'middle', 
      align = 'center' 
    } = req.body;

    if (!text || text.trim() === '') {
      return res.status(400).json({ error: 'Text is required' });
    }

    if (!templateBuffer) {
      return res.status(404).json({ error: 'Template not initialized' });
    }

    const templateMetadata = await sharp(templateBuffer).metadata();
    const { width, height } = templateMetadata;

    const svgText = createTextSVG(text, {
      fontSize: parseInt(fontSize),
      color,
      position,
      align,
      width,
      height
    });

    const outputBuffer = await sharp(templateBuffer)
      .composite([
        {
          input: Buffer.from(svgText),
          top: 0,
          left: 0,
        }
      ])
      .png()
      .toBuffer();

    res.set({
      'Content-Type': 'image/png',
      'Content-Disposition': 'attachment; filename="generated-image.png"',
      'Content-Length': outputBuffer.length
    });

    res.send(outputBuffer);

  } catch (error) {
    console.error('Error generating image:', error);
    res.status(500).json({ error: 'Failed to generate image' });
  }
});

// Serve frontend UI
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
