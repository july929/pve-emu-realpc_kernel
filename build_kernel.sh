apt-get update
apt-get install -y libacl1-dev libaio-dev libattr1-dev libcap-ng-dev libcurl4-gnutls-dev libepoxy-dev libfdt-dev libgbm-dev libgnutls28-dev libiscsi-dev libjpeg-dev libnuma-dev libpci-dev libpixman-1-dev libproxmox-backup-qemu0-dev librbd-dev libsdl1.2-dev libseccomp-dev libslirp-dev libspice-protocol-dev libspice-server-dev libsystemd-dev liburing-dev libusb-1.0-0-dev libusbredirparser-dev libvirglrenderer-dev meson python3-sphinx python3-sphinx-rtd-theme quilt xfslibs-dev
apt install -y dh-python asciidoc-base bison dwarves flex libdw-dev libelf-dev libiberty-dev libslang2-dev lz4 python3-dev xmlto rsync gawk rust-src rustfmt rust-clippy bindgen
ls
df -h
git clone git://git.proxmox.com/git/pve-kernel.git
cd pve-kernel
git reset --hard f109f2b7914ec516c081c3d31642671187dd3ab9 # bump version to 7.0.6-2-pve
apt install devscripts -y
mk-build-deps --install
git submodule update --init --recursive --force
cd submodules/zfsonlinux/
mk-build-deps --install
cd ../..
sed -i '/CPU_BASED_RDTSC_EXITING/d' submodules/ubuntu-kernel/arch/x86/kvm/vmx/vmx.h
sed -i 's/CPU_BASED_TPR_SHADOW/(CPU_BASED_TPR_SHADOW/g' submodules/ubuntu-kernel/arch/x86/kvm/vmx/vmx.h
sed -i 's/exec_control \&= ~(CPU_BASED_RDTSC_EXITING |/exec_control \&= ~(/g' submodules/ubuntu-kernel/arch/x86/kvm/vmx/vmx.c
sed -i 's/\/\* INTR_WINDOW_EXITING/exec_control |= CPU_BASED_RDTSC_EXITING;\n\t\/\* INTR_WINDOW_EXITING/g' submodules/ubuntu-kernel/arch/x86/kvm/vmx/vmx.c
sed -i 's/static u64 vmx_tertiary_exec_control/static u32 print_once = 1;\n\nstatic int handle_rdtsc(struct kvm_vcpu *vcpu)\n{ \n\tstatic u64 rdtsc_fake = 0;\n\tstatic u64 rdtsc_prev = 0;\n\tu64 rdtsc_real = rdtsc();\n\n\tif(print_once)\n\t{\n\t\tprintk("[handle_rdtsc] fake rdtsc vmx function is working\\n");\n\t\tprint_once = 0;\n\t\trdtsc_fake = rdtsc_real;\n\t}\n\n\tif(rdtsc_prev != 0)\n\t{\n\t\tif(rdtsc_real > rdtsc_prev)\n\t\t{\n\t\t\tu64 diff = rdtsc_real - rdtsc_prev;\n\t\t\tu64 fake_diff =  diff \/ 16;\n\t\t\trdtsc_fake += fake_diff;\n\t\t}\n\t}\n\tif(rdtsc_fake > rdtsc_real)\n\t{\n\t\trdtsc_fake = rdtsc_real;\n\t}\n\trdtsc_prev = rdtsc_real;\n\tvcpu->arch.regs[VCPU_REGS_RAX] = rdtsc_fake & -1u;\n\tvcpu->arch.regs[VCPU_REGS_RDX] = (rdtsc_fake >> 32) & -1u;  \n\n\treturn skip_emulated_instruction(vcpu);\n}\n\nstatic u64 vmx_tertiary_exec_control/g' submodules/ubuntu-kernel/arch/x86/kvm/vmx/vmx.c
sed -i 's/handle_notify,/handle_notify,\n\t[EXIT_REASON_RDTSC]      = handle_rdtsc,/g' submodules/ubuntu-kernel/arch/x86/kvm/vmx/vmx.c
sed -i 's/svm_set_intercept(svm, INTERCEPT_RSM);/svm_set_intercept(svm, INTERCEPT_RSM);\n\tsvm_set_intercept(svm, INTERCEPT_RDTSC);/g' submodules/ubuntu-kernel/arch/x86/kvm/svm/svm.c
sed -i 's/avic_unaccelerated_access_interception,/avic_unaccelerated_access_interception,\n\t[SVM_EXIT_RDTSC]           = handle_rdtsc_interception, \/\/added line Julyblog /g' submodules/ubuntu-kernel/arch/x86/kvm/svm/svm.c
sed -i 's/static int (\*const svm_exit_handlers/static u32 print_once = 1;\nstatic int handle_rdtsc_interception(struct kvm_vcpu \*vcpu){\n\tstatic u64 rdtsc_fake = 0;\n\tstatic u64 rdtsc_prev = 0;\n\tu64 rdtsc_real = rdtsc();\n\tif(print_once){\n\t\tprintk(KERN_ALERT "[handle_rdtsc] svm.c fake rdtsc svm function is working\\n");\n\t\tprint_once = 0;\n\t\trdtsc_fake = rdtsc_real;\n\t}\n\tif(rdtsc_prev != 0){\n\t\tif(rdtsc_real > rdtsc_prev){\n\t\t\tu64 diff = rdtsc_real - rdtsc_prev;\n\t\t\tu64 fake_diff =  diff \/ 16;\n\t\t\trdtsc_fake += fake_diff;\n\t\t}\n\t}\n\tif(rdtsc_fake > rdtsc_real)\n\t{\n\t\trdtsc_fake = rdtsc_real;\n\t}\n\trdtsc_prev = rdtsc_real;\n\tvcpu->arch.regs[VCPU_REGS_RAX] = rdtsc_fake \& -1u;\n\tvcpu->arch.regs[VCPU_REGS_RDX] = (rdtsc_fake >> 32) \& -1u;\n\treturn svm_skip_emulated_instruction(vcpu);\n}\nstatic int (\*const svm_exit_handlers/g' submodules/ubuntu-kernel/arch/x86/kvm/svm/svm.c
cd submodules/ubuntu-kernel/
git diff > qemu-autoGenPatch.patch
cp qemu-autoGenPatch.patch ../..
cd ../..
make
