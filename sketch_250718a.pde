import processing.sound.*;

// --- KELAS UNTUK ANIMASI GIF ---
class AnimatedCharacter {
  PImage[] frames;
  int frameCount;
  int currentFrame = 0;
  float frameRate = 8; // fps
  float lastUpdate = 0;
  boolean isFlipped = false;
  
  AnimatedCharacter(String prefix, int count) {
    frameCount = count;
    frames = new PImage[frameCount];
    for (int i = 0; i < frameCount; i++) {
      try {
        frames[i] = loadImage(prefix + i + ".gif");
      } catch (Exception e) {
        println("Error loading frame: " + prefix + i + ".gif");
        frames[i] = createImage(100, 100, ARGB);
        frames[i].loadPixels();
        for (int j = 0; j < frames[i].pixels.length; j++) {
          frames[i].pixels[j] = color(255, 0, 255, 100);
        }
        frames[i].updatePixels();
      }
    }
  }
  
  void setFlip(boolean flip) {
    isFlipped = flip;
  }
  
  void update() {
    if (frameCount <= 1) return;
    if (millis() - lastUpdate > 1000 / frameRate) {
      currentFrame = (currentFrame + 1) % frameCount;
      lastUpdate = millis();
    }
  }
  
  void display(float x, float y, float h) {
    if (frameCount == 0 || frames[currentFrame] == null) return;
    PImage img = frames[currentFrame];
    float aspect = (float)img.width / img.height;
    float w = h * aspect;
    pushMatrix();
    translate(x, y);
    if (isFlipped) scale(-1, 1);
    image(img, -w/2, -h, w, h);
    popMatrix();
  }
}

// --- Variabel Global untuk Kontrol Animasi ---
int currentScene = 1;
long sceneStartTime;
float sceneDuration = 36000; // 36 detik per scene

// --- Variabel untuk Latar ---
color skyColorScene12 = color(170, 180, 190);
color skyColorScene4 = color(180, 200, 210);
color skyColorScene5 = color(150, 200, 255);
color groundColor = color(150, 120, 80);
float sunX, sunY, sunRadius = 60;
color sunColor = color(255, 200, 0);
float heatWaveOffset = 0, heatWaveSpeed = 0.05;

// --- Variabel untuk Partikel ---
DustParticleSystem dustParticleSystem;
int numDustParticles = 100;
PollutionParticleSystem pollutionSystem;

// --- Variabel Karakter Animasi ---
AnimatedCharacter rafiDiam, rafiBerjalan;
AnimatedCharacter penebang1Berjalan, penebang1Diam, penebang1DiMasjid;
AnimatedCharacter penebang2Berjalan, penebang2Diam, penebang2DiMasjid;
AnimatedCharacter penebang3Berjalan, penebang3Diam, penebang3DiMasjid;
AnimatedCharacter ustadDiam;
AnimatedCharacter warga1Berjalan, warga1Diam;
AnimatedCharacter warga2Berjalan, warga2Diam;

// --- Variabel untuk Elemen Tambahan ---
PImage latar3Image, bungaMatahari;
Cloud[] clouds;
Bird[] birds;
int numClouds = 5, numBirds = 3;

// --- Kelas Cloud, Bird, PollutionParticleSystem, Particle, DustParticleSystem ---
class Cloud { float x, y, speed, size; Cloud() { reset(); } void reset() { x = random(-200, width + 200); y = random(50, 150); speed = random(0.2, 0.5); size = random(80, 150); } void update() { x += speed; if (x > width + 200) { reset(); x = -200; } } void display() { noStroke(); fill(255, 255, 255, 200); ellipse(x, y, size, size * 0.6); ellipse(x + size * 0.3, y - size * 0.2, size * 0.7, size * 0.5); ellipse(x + size * 0.3, y + size * 0.2, size * 0.7, size * 0.5); ellipse(x + size * 0.6, y, size * 0.8, size * 0.7); } }
class Bird { float x, y, speed, wingAngle = 0, wingSpeed = 0.1; Bird() { reset(); } void reset() { x = random(-200, width + 200); y = random(50, 150); speed = random(2, 4); } void update() { x += speed; wingAngle += wingSpeed; if (x > width + 200) { reset(); x = -200; } } void display() { pushMatrix(); translate(x, y); fill(50); ellipse(0, 0, 20, 10); ellipse(-8, -2, 10, 10); fill(255); ellipse(-10, -3, 4, 4); fill(0); ellipse(-10, -3, 2, 2); fill(255, 150, 0); triangle(-13, -2, -16, -2, -14, 0); fill(50); float wingY = sin(wingAngle) * 5; ellipse(0, wingY, 15, 8); popMatrix(); } }
class PollutionParticleSystem { ArrayList<Particle> particles; int maxParticles; PollutionParticleSystem(int num) { maxParticles = num; particles = new ArrayList<Particle>(); for (int i = 0; i < maxParticles; i++) particles.add(new Particle()); } void updateAndDisplay() { for (int i = particles.size() - 1; i >= 0; i--) { Particle p = particles.get(i); p.update(); p.display(color(150, 150, 150, 80)); if (p.isDead()) particles.remove(i); } while (particles.size() < maxParticles) particles.add(new Particle()); } }
class Particle { PVector position, velocity; float size, alpha; Particle() { reset(); } void reset() { position = new PVector(random(width), random(height * 0.3, height * 0.8)); velocity = new PVector(random(-0.5, 0.5), random(-0.2, 0.2)); size = random(5, 20); alpha = random(50, 150); } void update() { position.add(velocity); alpha -= 0.5; } void display(color particleColor) { noStroke(); fill(red(particleColor), green(particleColor), blue(particleColor), alpha); ellipse(position.x, position.y, size, size); } boolean isDead() { return (alpha <= 0 || position.y < 0 || position.x > width + 50 || position.x < -50); } }
class DustParticleSystem { ArrayList<Particle> particles; int maxParticles; DustParticleSystem(int num) { maxParticles = num; particles = new ArrayList<Particle>(); for (int i = 0; i < maxParticles; i++) particles.add(new Particle()); } void updateAndDisplay() { updateAndDisplay(color(200, 170, 120, 100)); } void updateAndDisplay(color particleColor) { for (int i = particles.size() - 1; i >= 0; i--) { Particle p = particles.get(i); p.update(); p.display(particleColor); if (p.isDead()) particles.remove(i); } while (particles.size() < maxParticles) particles.add(new Particle()); } }

// --- Variabel Audio ---
SoundFile bgMusic;
SoundFile[][] sceneNarrations = new SoundFile[6][]; // Indeks 1-5 untuk scene 1-5
int currentNarrationIndex = 0; // Untuk melacak urutan narasi dalam scene
int lastScene = 0; // Untuk melacak perubahan scene

void setup() {
  size(1000, 600);
  sunX = width * 0.85;
  sunY = height * 0.15;

  dustParticleSystem = new DustParticleSystem(numDustParticles);
  pollutionSystem = new PollutionParticleSystem(100);

  // Memuat Animasi Karakter
  penebang1Berjalan = new AnimatedCharacter("penebang1_berjalan_", 3);
  penebang1Diam = new AnimatedCharacter("penebang1_diam_", 2);
  penebang1DiMasjid = new AnimatedCharacter("penebang1_dimasjid_", 2);
  penebang2Berjalan = new AnimatedCharacter("penebang2_berjalan_", 3);
  penebang2Diam = new AnimatedCharacter("penebang2_diam_", 1);
  penebang2DiMasjid = new AnimatedCharacter("penebang2_dimasjid_", 1);
  penebang3Berjalan = new AnimatedCharacter("penebang3_berjalan_", 3);
  penebang3Diam = new AnimatedCharacter("penebang3_diam_", 2);
  penebang3DiMasjid = new AnimatedCharacter("penebang3_dimasjid_", 1);
  rafiDiam = new AnimatedCharacter("rafi_diam_", 2);
  rafiBerjalan = new AnimatedCharacter("rafi_berjalan_", 4);
  ustadDiam = new AnimatedCharacter("ustad_diam_", 2);
  warga1Berjalan = new AnimatedCharacter("warga1_berjalan_", 6);
  warga1Diam = new AnimatedCharacter("warga1_diam_", 1);
  warga2Berjalan = new AnimatedCharacter("warga2_berjalan_", 3);
  warga2Diam = new AnimatedCharacter("warga2_diam_", 2);

  try { latar3Image = loadImage("latar3.jpg"); } catch (Exception e) { println("Warning: latar3.jpg tidak ditemukan"); }
  try { bungaMatahari = loadImage("BungaMatahari.gif"); } catch (Exception e) { println("Warning: BungaMatahari.gif tidak ditemukan"); }
  
  clouds = new Cloud[numClouds];
  for (int i = 0; i < numClouds; i++) clouds[i] = new Cloud();
  birds = new Bird[numBirds];
  for (int i = 0; i < numBirds; i++) birds[i] = new Bird();

  sceneStartTime = millis(); 
  
  // Inisialisasi Audio
  try {
    // Musik latar
    bgMusic = new SoundFile(this, "data/background_music.mp3");
    bgMusic.loop();
    bgMusic.amp(0.3); // Volume musik 30%
    
    // Narasi per scene
    // Scene 1: 1 file
    sceneNarrations[1] = new SoundFile[] {
      new SoundFile(this, "data/voice1.mp3") // Scene 1 opening
    };
    
    // Scene 2: 4 file
    sceneNarrations[2] = new SoundFile[] {
      new SoundFile(this, "data/voice2.mp3"), // Scene 2 awal
      new SoundFile(this, "data/voice3.mp3"), // Rafi berteriak
      new SoundFile(this, "data/voice4.mp3"), // Penebang menjawab
      new SoundFile(this, "data/voice5.mp3")  // Akhir scene 2
    };
    
    // Scene 3: 2 file
    sceneNarrations[3] = new SoundFile[] {
      new SoundFile(this, "data/voice6.mp3"), // Awal scene 3
      new SoundFile(this, "data/voice7.mp3")  // Ustad ceramah
    };
    
    // Scene 4: 1 file
    sceneNarrations[4] = new SoundFile[] {
      new SoundFile(this, "data/voice8.mp3") // Scene 4
    };
    
    // Scene 5: Tidak ada narasi
    sceneNarrations[5] = new SoundFile[] {};
    
    // Atur volume semua narasi
    for (int i = 1; i <= 5; i++) {
      if (sceneNarrations[i] != null) {
        for (SoundFile sf : sceneNarrations[i]) {
          sf.amp(0.8); // Volume narasi 80%
        }
      }
    }
    
  } catch (Exception e) {
    println("Error loading sound files: " + e.getMessage());
  }
}

void draw() {
  long elapsedTime = millis() - sceneStartTime;
  
  // Deteksi perubahan scene
  if (currentScene != lastScene) {
    // Hentikan semua narasi scene sebelumnya
    stopAllNarrations(lastScene);
    
    // Reset index narasi
    currentNarrationIndex = 0;
    
    // Mainkan narasi pertama scene baru (jika ada)
    playCurrentNarration();
    
    lastScene = currentScene;
    sceneStartTime = millis(); // Reset waktu scene
    elapsedTime = 0;
  }
  
  // Periksa apakah perlu memainkan narasi berikutnya
  if (shouldPlayNextNarration()) {
    currentNarrationIndex++;
    playCurrentNarration();
  }
  
  // Scene otomatis ganti setelah durasi tertentu
  if (elapsedTime > sceneDuration) {
    currentScene = (currentScene % 5) + 1;
    // Perubahan scene akan ditangani di loop berikutnya
    return;
  }

  // Update semua animasi
  penebang1Berjalan.update(); penebang1Diam.update(); penebang1DiMasjid.update();
  penebang2Berjalan.update(); penebang2Diam.update(); penebang2DiMasjid.update();
  penebang3Berjalan.update(); penebang3Diam.update(); penebang3DiMasjid.update();
  ustadDiam.update(); warga1Berjalan.update(); warga1Diam.update();
  warga2Berjalan.update(); warga2Diam.update(); rafiDiam.update(); rafiBerjalan.update();

  switch (currentScene) {
    case 1: drawScene1(elapsedTime); break;
    case 2: drawScene2(elapsedTime); break;
    case 3: drawScene3(elapsedTime); break;
    case 4: drawScene4(elapsedTime); break;
    case 5: drawScene5(elapsedTime); break;
  }
}

// --- Fungsi Audio Helper ---
boolean shouldPlayNextNarration() {
  // Cek jika ada narasi berikutnya dan yang saat ini sudah selesai
  if (sceneNarrations[currentScene] != null && 
      sceneNarrations[currentScene].length > currentNarrationIndex) {
      
    SoundFile current = sceneNarrations[currentScene][currentNarrationIndex];
    return !current.isPlaying() && 
           currentNarrationIndex < sceneNarrations[currentScene].length - 1;
  }
  return false;
}

void playCurrentNarration() {
  if (sceneNarrations[currentScene] != null && 
      currentNarrationIndex < sceneNarrations[currentScene].length) {
    
    SoundFile sf = sceneNarrations[currentScene][currentNarrationIndex];
    if (!sf.isPlaying()) {
      sf.play();
      println("Memainkan narasi scene " + currentScene + " bagian " + (currentNarrationIndex+1));
    }
  }
}

void stopAllNarrations(int scene) {
  if (scene >= 1 && scene <= 5 && sceneNarrations[scene] != null) {
    for (SoundFile sf : sceneNarrations[scene]) {
      if (sf.isPlaying()) {
        sf.stop();
        println("Menghentikan narasi scene " + scene);
      }
    }
  }
}

// --- FUNGSI UNTUK MENGGAMBAR SCENE 1 ---
void drawScene1(long elapsedTime) {
  // Efek Slow Zoom-in ke arah pohon tua
  float zoomFactor = map(elapsedTime, 0, sceneDuration, 1.0, 1.5);
  float targetX = width / 2;
  float targetY = height * 0.7;

  pushMatrix();
  translate(width / 2, height / 2);
  scale(zoomFactor);
  translate(-targetX, -targetY);

  // Latar langit & tanah
  drawExtendedBackground(skyColorScene12, groundColor);

  // Matahari dan awan
  drawSun();
  for (Cloud c : clouds) {
    c.update();
    c.display();
  }

  // Tinggi tanah: 140 px dari bawah → Y tanah = height - 140
  float groundY = height * 0.75;

  // Tunggul pohon (ditaruh menyentuh tanah, bukan di langit)
  drawTreeStump(width * 0.08, groundY, 50);
  drawTreeStump(width * 0.25, groundY + 5, 60);
  drawTreeStump(width * 0.70, groundY + 3, 45);
  drawTreeStump(width * 0.90, groundY + 2, 55);

  // Rumah-rumah diratakan dan berada tepat di atas tanah
  drawHouse(width * 0.15, groundY - 80, 100, 80);
  drawHouse(width * 0.35, groundY - 90, 110, 90);
  drawHouse(width * 0.80, groundY - 80, 100, 80);

  // Pohon tua besar (akar menyentuh tanah)
  drawOldTree(width / 2, groundY, 300);

  // Partikel debu & polusi
  dustParticleSystem.updateAndDisplay();
  pollutionSystem.updateAndDisplay();

  popMatrix();
}

// --- FUNGSI UNTUK MENGGAMBAR SCENE 2 ---
void drawScene2(long elapsedTime) {
  drawExtendedBackground(skyColorScene12, groundColor);
  drawSun();
  for (Cloud c : clouds) { c.update(); c.display(); }
  
  drawTreeStump(width * 0.08, height * 0.6, 50);
  drawTreeStump(width * 0.25, height * 0.62, 60);
  drawTreeStump(width * 0.70, height * 0.63, 45);
  drawTreeStump(width * 0.90, height * 0.61, 55);
  // PERUBAHAN: Posisi Y rumah disesuaikan
  drawHouse(width * 0.15, height * 0.6, 100, 80);
  drawHouse(width * 0.35, height * 0.6, 110, 90);
  drawHouse(width * 0.80, height * 0.6, 100, 80);
  drawOldTree(width / 2, height * 0.85, 300);

  float charGroundY = height * 0.85;

  // Animasi Penebang (dari KANAN ke KIRI)
  float woodcutterStartX = width + 150;
  float woodcutterStopX = width * 0.65;
  float woodcutterMovePhaseDuration = sceneDuration * 0.4;
  
  float wcCurrentX = (elapsedTime < woodcutterMovePhaseDuration) ?
    map(elapsedTime, 0, woodcutterMovePhaseDuration, woodcutterStartX, woodcutterStopX) : woodcutterStopX;
  
  if (elapsedTime < woodcutterMovePhaseDuration) {
    penebang1Berjalan.setFlip(true); penebang1Berjalan.display(wcCurrentX, charGroundY, 120);
    penebang2Berjalan.setFlip(true); penebang2Berjalan.display(wcCurrentX + 70, charGroundY + 10, 110);
    penebang3Berjalan.setFlip(true); penebang3Berjalan.display(wcCurrentX + 140, charGroundY - 5, 105);
  } else {
    penebang1Diam.setFlip(true); penebang1Diam.display(wcCurrentX, charGroundY, 120);
    penebang2Diam.setFlip(true); penebang2Diam.display(wcCurrentX + 70, charGroundY + 10, 110);
    penebang3Diam.setFlip(true); penebang3Diam.display(wcCurrentX + 140, charGroundY - 5, 105);
  }

  // PERUBAHAN: Animasi Rafi dibuat lebih cepat untuk menunjukkan kepanikan/berlari
  float rafiStartX = -150;
  float rafiStopX = width * 0.35;
  float rafiDelayStart = sceneDuration * 0.1;
  float rafiMovePhaseDuration = sceneDuration * 0.25; // Durasi dipercepat dari 0.3 -> 0.25

  if (elapsedTime > rafiDelayStart && elapsedTime < rafiDelayStart + rafiMovePhaseDuration) {
    float rafiCurrentX = map(elapsedTime, rafiDelayStart, rafiDelayStart + rafiMovePhaseDuration, rafiStartX, rafiStopX);
    rafiBerjalan.setFlip(false);
    rafiBerjalan.display(rafiCurrentX, charGroundY, 110);
  } else if (elapsedTime >= rafiDelayStart + rafiMovePhaseDuration) {
    rafiDiam.display(rafiStopX, charGroundY, 110);
  }
  
  dustParticleSystem.updateAndDisplay();
  pollutionSystem.updateAndDisplay();
}

// --- FUNGSI UNTUK MENGGAMBAR SCENE 3 ---
void drawScene3(long elapsedTime) {
  if (latar3Image != null) { image(latar3Image, 0, 0, width, height); } 
  else { background(200, 220, 230); }

  // PERUBAHAN: Penataan ulang posisi karakter untuk adegan musyawarah yang lebih alami
  float centerX = width / 2;
  float groundY = height * 0.8; 

  // Ustaz duduk di dekat tengah, memberi dukungan
  ustadDiam.display(centerX + 60, groundY - 40, 150);
  
  // Rafi berdiri di depannya, seolah sedang berbicara
  rafiDiam.display(centerX - 60, groundY - 20, 120);

  // Warga dan penebang duduk dalam formasi setengah lingkaran mendengarkan
  penebang1DiMasjid.display(width * 0.20, groundY + 50, 100);
  penebang2DiMasjid.display(width * 0.35, groundY + 70, 100);
  warga1Diam.display(width * 0.50, groundY + 80, 90);
  penebang3DiMasjid.display(width * 0.65, groundY + 70, 100);
  warga2Diam.display(width * 0.80, groundY + 50, 90);
}

// --- FUNGSI UNTUK MENGGAMBAR SCENE 4 ---
void drawScene4(long elapsedTime) {
  drawBackgroundGreen(skyColorScene4, color(150, 170, 100));
  drawSun();
  for (Cloud c : clouds) { c.update(); c.display(); }
  
  // PERUBAHAN: Posisi Y rumah disesuaikan
  drawHouse(width * 0.15, height * 0.6, 100, 80);
  drawHouse(width * 0.80, height * 0.6, 100, 80);
  drawOldTree(width / 2, height * 0.85, 300);

  // PERUBAHAN: Montase warga bergotong royong menanam, lebih banyak karakter
  float charGroundY = height * 0.88;
  
  // Rafi mengawasi dan ikut menanam
  rafiDiam.display(width * 0.1, charGroundY, 110);
  
  // Para penebang yang telah menyesal, kini ikut menanam
  penebang1Diam.display(width * 0.3, charGroundY - 10, 120);
  penebang2Diam.display(width * 0.75, charGroundY, 110);
  
  // Warga lain ikut membantu
  warga1Berjalan.setFlip(true); // Bergerak ke kiri
  warga1Berjalan.display(map(elapsedTime % 10000, 0, 10000, width + 50, width * 0.4), charGroundY, 100);
  warga2Diam.display(width * 0.9, charGroundY + 5, 100);
  
  // PERUBAHAN: Menambah lebih banyak bibit pohon untuk menunjukkan usaha bersama
  drawSapling(width * 0.28, height * 0.85, 50);
  drawSapling(width * 0.45, height * 0.88, 45);
  drawSapling(width * 0.6, height * 0.9, 55);
  drawSapling(width * 0.73, height * 0.86, 50);
  drawSapling(width * 0.15, height * 0.89, 48);
  
  if (bungaMatahari != null) {
    imageMode(CENTER);
    image(bungaMatahari, width * 0.2, height * 0.8, 60, 60);
    image(bungaMatahari, width * 0.5, height * 0.85, 50, 50);
    image(bungaMatahari, width * 0.7, height * 0.82, 55, 55);
    image(bungaMatahari, width * 0.9, height * 0.78, 45, 45);
    imageMode(CORNER);
  }
}

// --- FUNGSI UNTUK MENGGAMBAR SCENE 5 ---
void drawScene5(long elapsedTime) {
  // PERUBAHAN: Menambahkan efek "Slow Pull-out" (zoom out) untuk menunjukkan hasil akhir
  float zoomFactor = map(elapsedTime, 0, sceneDuration, 1.5, 1.0);
  
  pushMatrix();
  translate(width / 2, height / 2);
  scale(zoomFactor);
  translate(-width / 2, -height / 2);

  drawBackgroundGreen(skyColorScene5, color(100, 150, 70));
  
  drawSun();
  for (Cloud c : clouds) { c.update(); c.display(); }
  for (Bird b : birds) { b.update(); b.display(); }

  // PERUBAHAN: Posisi Y rumah disesuaikan
  drawHouse(width * 0.15, height * 0.6, 100, 80);
  drawHouse(width * 0.35, height * 0.6, 110, 90);
  drawHouse(width * 0.80, height * 0.6, 100, 80);

  // Pohon-pohon telah tumbuh besar dan rimbun
  drawOldTree(width / 2, height * 0.85, 300);
  drawOldTree(width * 0.2, height * 0.85, 180); 
  drawOldTree(width * 0.8, height * 0.88, 200);
  drawOldTree(width * 0.05, height * 0.9, 150);
  drawOldTree(width * 0.95, height * 0.9, 160);
  drawGrass();
  
  // PERUBAHAN: Menambahkan lebih banyak warga yang menikmati suasana asri
  float charGroundY = height * 0.9;
  rafiDiam.display(width * 0.3, charGroundY, 90); 
  warga1Diam.display(width * 0.7, charGroundY, 100);
  penebang1Diam.display(width * 0.55, charGroundY - 5, 120); // Penebang ikut menikmati hasil
  warga2Berjalan.setFlip(false);
  warga2Berjalan.display(map(elapsedTime % 12000, 0, 12000, -50, width + 50), charGroundY - 10, 100);

  if (bungaMatahari != null) {
    imageMode(CENTER);
    for (int i = 0; i < 10; i++) {
      float x = map(i, 0, 9, 50, width - 50);
      float y = height * 0.85 + sin(i * 0.5) * 20;
      image(bungaMatahari, x, y, 40, 40);
    }
    imageMode(CORNER);
  }
  
  dustParticleSystem.updateAndDisplay(color(100, 200, 100, 80));
  
  popMatrix();
}

// --- FUNGSI-FUNGSI HELPER ---
void drawExtendedBackground(color currentSkyColor, color currentGroundColor) {
  background(currentSkyColor);
  float groundY = height * 0.6; // Tanah dimulai dari 60% layar
  noStroke();
  fill(currentGroundColor);
  rect(0, groundY, width, height - groundY);
  noFill();
  stroke(200, 170, 120, 150);
  strokeWeight(1.5);
  beginShape();
  vertex(0, groundY);
  for (int i = 0; i < width; i += 10) {
    float yOffset = map(noise(i * 0.01 + heatWaveOffset), 0, 1, -10, 10);
    curveVertex(i, groundY + yOffset);
  }
  vertex(width, groundY);
  endShape();
  heatWaveOffset += heatWaveSpeed;
}

void drawBackgroundGreen(color currentSkyColor, color currentGroundColor) {
  background(currentSkyColor);
  noStroke();
  // Tanah hijau dimulai dari 50% layar
  for (int i = height / 2; i < height; i++) {
    float inter = map(i, height / 2, height, 0, 1);
    color c = lerpColor(currentGroundColor, color(red(currentGroundColor)-30, green(currentGroundColor)-30, blue(currentGroundColor)), inter);
    stroke(c);
    line(0, i, width, i);
  }
  noStroke();
}

void drawSun() { noStroke(); fill(sunColor); ellipse(sunX, sunY, sunRadius * 2, sunRadius * 2); for (int i = 0; i < 5; i++) { fill(255, 200, 0, 50 - i * 10); ellipse(sunX, sunY, sunRadius * 2 + i * 20, sunRadius * 2 + i * 20); } }
void drawHouse(float x, float y, float houseWidth, float houseHeight) { noStroke(); fill(220, 200, 150); rect(x, y - houseHeight, houseWidth, houseHeight); fill(150, 80, 50); triangle(x - houseWidth * 0.1, y - houseHeight, x + houseWidth * 0.5, y - houseHeight - houseHeight * 0.6, x + houseWidth * 1.1, y - houseHeight); fill(100, 50, 30); rect(x + houseWidth * 0.35, y - houseHeight * 0.6, houseWidth * 0.3, houseHeight * 0.6); fill(150, 200, 255); rect(x + houseWidth * 0.1, y - houseHeight * 0.8, houseWidth * 0.2, houseHeight * 0.2); rect(x + houseWidth * 0.7, y - houseHeight * 0.8, houseWidth * 0.2, houseHeight * 0.2); fill(0, 0, 0, 30); ellipse(x + houseWidth/2, y, houseWidth * 0.8, 10); }
void drawOldTree(float x, float y, float treeHeight) { float trunkWidth = treeHeight * 0.08; float trunkHeight = treeHeight * 0.6; fill(80, 60, 30); rect(x - trunkWidth / 2, y - trunkHeight, trunkWidth, trunkHeight); stroke(60, 40, 10, 150); strokeWeight(2); line(x - trunkWidth * 0.4, y - trunkHeight * 0.2, x - trunkWidth * 0.2, y - trunkHeight * 0.6); line(x + trunkWidth * 0.3, y - trunkHeight * 0.5, x + trunkWidth * 0.1, y - trunkHeight * 0.9); noStroke(); fill(70, 120, 50); ellipse(x, y - trunkHeight - treeHeight * 0.15, treeHeight * 0.6, treeHeight * 0.5); ellipse(x - treeHeight * 0.18, y - trunkHeight - treeHeight * 0.3, treeHeight * 0.45, treeHeight * 0.4); ellipse(x + treeHeight * 0.18, y - trunkHeight - treeHeight * 0.28, treeHeight * 0.48, treeHeight * 0.42); ellipse(x - treeHeight * 0.1, y - trunkHeight - treeHeight * 0.05, treeHeight * 0.4, treeHeight * 0.35); ellipse(x + treeHeight * 0.1, y - trunkHeight - treeHeight * 0.07, treeHeight * 0.42, treeHeight * 0.38); stroke(80, 60, 30); strokeWeight(trunkWidth * 0.5); line(x - trunkWidth/2, y - trunkHeight * 0.7, x - treeHeight * 0.15, y - trunkHeight - treeHeight * 0.1); line(x + trunkWidth/2, y - trunkHeight * 0.6, x + treeHeight * 0.15, y - trunkHeight - treeHeight * 0.1); noStroke(); fill(0, 0, 0, 50); ellipse(x, y, trunkWidth * 4, 25); }
void drawTreeStump(float x, float y, float stumpSize) { noStroke(); fill(100, 70, 40); ellipse(x, y, stumpSize, stumpSize * 0.7); fill(80, 50, 20); ellipse(x, y - stumpSize * 0.3, stumpSize * 0.8, stumpSize * 0.8); stroke(60, 40, 10, 150); strokeWeight(0.8); ellipse(x, y - stumpSize * 0.3, stumpSize * 0.5, stumpSize * 0.5); ellipse(x, y - stumpSize * 0.3, stumpSize * 0.2, stumpSize * 0.2); noStroke(); fill(0, 0, 0, 30); ellipse(x, y + 5, stumpSize * 0.8, 8); }
void drawSapling(float x, float y, float saplingHeight) { float stemWidth = saplingHeight * 0.1; float stemHeight = saplingHeight * 0.6; fill(100, 70, 40); rect(x - stemWidth / 2, y - stemHeight, stemWidth, stemHeight); fill(100, 180, 80); ellipse(x, y - stemHeight - saplingHeight * 0.1, saplingHeight * 0.4, saplingHeight * 0.3); ellipse(x - saplingHeight * 0.05, y - stemHeight - saplingHeight * 0.05, saplingHeight * 0.3, saplingHeight * 0.25); ellipse(x + saplingHeight * 0.05, y - stemHeight - saplingHeight * 0.07, saplingHeight * 0.32, saplingHeight * 0.27); }
void drawGrass() { stroke(0, 150, 0); strokeWeight(1); for (int i = 0; i < 200; i++) { float x = random(width); float h = random(5, 15); line(x, height, x, height - h); } noStroke(); }
