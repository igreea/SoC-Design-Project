# SoC-Design-Project
Fixed-kernel 2D convolution accelerator  
===========================================
> 2025-1 SoC Design


## 프로젝트 개요
본 프로젝트에서는 주어진 제약조건에서 Verilog를 통해 3x3 Sobel/Gaussian 커널에 대한 컨볼루션 연산을 수행하는 가속기를 개발하고, 시뮬레이션을 통해 출력 데이터를 검증합니다. Synthesis 및 implementation 까지 완료하였으며, RTL simulation 및 post-simulation(implementation)을 통해 얻은 클럭 사이클 수와 연산 시간을 최소화하는 것을 목표로 진행하였습니다.


## 상세 설명
- **Project 1**: 흑백 이미지 데이터(input.mem)에 대한 x, y 방향 3x3 sobel 커널 컨볼루션 연산 지원
- **Project 2**: RGB888 이미지 데이터에 대한 3x3 gaussian 커널 컨볼루션 연산 지원
- **공통**: 입력 이미지 사이즈 32x32, 출력 이미지 사이즈 30x30
- **제약 조건**: 입력 이미지(900픽셀) 데이터는 input.mem에 저장되어 있으며, 한 클럭당 한 픽셀 씩 읽어올 수 있음. 목표 주파수 100MHz
- **평가**: 정답 데이터(output.mem)를 바탕으로 line-by-line 비교를 통해 올바르게 커널 연산이 수행되었는지 확인
- **목표 디바이스 / 시뮬레이션 툴**: Xilinx Artix-7 XC7A75T-1 FGG484 / Vivado 2023.2


## 전체 구조 개요
<img width="400" height="708" alt="image" src="https://github.com/user-attachments/assets/f9048742-0065-4e45-8ff4-1775352f56d2" />


## Synthesis

1. Project 1 (Sobel Kernel)
<img width="600" height="305" alt="image" src="https://github.com/user-attachments/assets/56949517-1db5-4e73-b634-28c2bf0d20fc" />
<img width="600" height="245" alt="image" src="https://github.com/user-attachments/assets/334c519f-1c7a-4de3-9b4b-4e54a0c0e9da" />
<img width="600" height="196" alt="image" src="https://github.com/user-attachments/assets/abb4a140-cf5c-4db0-b77c-37be60861d8d" />
   
<br><br>

2. Project 2 (Gaussian Kernel)
<img width="600" height="289" alt="image" src="https://github.com/user-attachments/assets/306dec97-6e8d-4b14-a93b-1bd350b318d7" />
<img width="600" height="253" alt="image" src="https://github.com/user-attachments/assets/92690ab0-95f3-4841-888a-b45f04f3f4c1" />
<img width="600" height="200" alt="image" src="https://github.com/user-attachments/assets/6abc6cd5-119a-4b64-a3dc-0df6176ea525" />

   
<br><br>

## Implementation & Post-Simulation


1. Project 1 (Sobel Kernel)
<img width="900" height="220" alt="image" src="https://github.com/user-attachments/assets/c56e8230-6440-4cd5-a648-fecebe32e7b8" />
<img width="900" height="252" alt="image" src="https://github.com/user-attachments/assets/568d90d9-80dc-4745-ba79-13c6c8ad76a6" />
<img width="900" height="149" alt="image" src="https://github.com/user-attachments/assets/5a340661-7cba-4689-bc9c-51e8255266be" />

Execution Time: 10,404,897 ps

<br>

2. Project 2 (gaussian Kernel)
<img width="900" height="212" alt="image" src="https://github.com/user-attachments/assets/b37faf40-5bfb-40df-adc6-4f34640c701e" />
<img width="900" height="256" alt="image" src="https://github.com/user-attachments/assets/a4e8a464-706c-44f7-8069-59fab4adc1c2" />
<img width="900" height="169" alt="image" src="https://github.com/user-attachments/assets/9a5b70f0-639f-46f6-9a24-bb5329271621" />

Execution Time: 10,396,805 ps




