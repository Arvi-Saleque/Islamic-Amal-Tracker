const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const svgContent = `<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
  <!-- Background -->
  <rect width="1024" height="1024" fill="#1A1A1A" rx="180"/>
  
  <!-- Main mosque body -->
  <rect x="200" y="520" width="624" height="330" fill="#D4AF37"/>
  
  <!-- Main dome -->
  <ellipse cx="512" cy="440" rx="260" ry="160" fill="#D4AF37"/>
  
  <!-- Left minaret -->
  <rect x="110" y="360" width="65" height="490" fill="#D4AF37"/>
  <polygon points="142,240 175,360 110,360" fill="#D4AF37"/>
  <circle cx="142" cy="220" r="22" fill="#D4AF37"/>
  
  <!-- Right minaret -->  
  <rect x="849" y="360" width="65" height="490" fill="#D4AF37"/>
  <polygon points="882,240 914,360 849,360" fill="#D4AF37"/>
  <circle cx="882" cy="220" r="22" fill="#D4AF37"/>
  
  <!-- Small domes -->
  <ellipse cx="310" cy="490" rx="75" ry="55" fill="#D4AF37"/>
  <ellipse cx="714" cy="490" rx="75" ry="55" fill="#D4AF37"/>
  
  <!-- Door -->
  <rect x="432" y="640" width="160" height="210" rx="80" fill="#1A1A1A"/>
  
  <!-- Windows -->
  <circle cx="310" cy="610" r="38" fill="#1A1A1A"/>
  <circle cx="714" cy="610" r="38" fill="#1A1A1A"/>
  
  <!-- Crescent moon on main dome -->
  <circle cx="512" cy="300" r="42" fill="#D4AF37"/>
  <circle cx="530" cy="290" r="36" fill="#1A1A1A"/>
</svg>`;

async function generateIcons() {
    const outputDir = path.join(__dirname, 'assets', 'icons');
    
    // Create directory if not exists
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }
    
    // Generate main app icon (1024x1024)
    await sharp(Buffer.from(svgContent))
        .resize(1024, 1024)
        .png()
        .toFile(path.join(outputDir, 'app_icon.png'));
    
    console.log('✅ app_icon.png generated');
    
    // Generate foreground icon for adaptive icons
    await sharp(Buffer.from(svgContent))
        .resize(1024, 1024)
        .png()
        .toFile(path.join(outputDir, 'app_icon_foreground.png'));
    
    console.log('✅ app_icon_foreground.png generated');
    
    console.log('\n🎉 Icons generated successfully!');
    console.log('Now run: flutter pub get && dart run flutter_launcher_icons');
}

generateIcons().catch(console.error);
