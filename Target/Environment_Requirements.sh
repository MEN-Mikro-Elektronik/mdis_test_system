#! /bin/bash
function cpu_requirement_id {
    local cpu=${1}
    case "${cpu}" in
        f23p)
            echo "    MEN_13MD05-90_SA_1000"
            ;;
        f26)
            echo "    MEN_13MD05-90_SA_1010"
            ;;
        g23)
            echo "    MEN_13MD05-90_SA_1020"
            ;;
        g25a)
            echo "    MEN_13MD05-90_SA_1030"
            ;;
        cb70)
            echo "    MEN_13MD05-90_SA_1040"
            ;;
        a25)
            echo "    MEN_13MD05-90_SA_1050"
            ;;
        sc24)
            echo "    MEN_13MD05-90_SA_1060"
            ;;
        sc25)
            echo "    MEN_13MD05-90_SA_1070"
            ;;
        sc31)
            echo "    MEN_13MD05-90_SA_1080"
            ;;
        *)
            ;;
    esac
}

function os_requirement_id {
    local os=${1}
    case "${os}" in
        ubuntu)
            echo "    MEN_13MD05-90_SA_0010"
            ;;
        centos)
            echo "    MEN_13MD05-90_SA_0020"
            ;;
        debian)
            echo "    MEN_13MD05-90_SA_0030"
            ;;
        *)
            ;;
    esac
}

function kernel_requirement_id {
    local kernel=${1}
    case "${kernel}" in
        lts)
            echo "    MEN_13MD05-90_SA_0040"
            ;;
        latest)
            echo "    MEN_13MD05-90_SA_0045"
            ;;
        *)
            ;;
    esac
}

function arch_requirement_id {
    local arch=${1}
    case "${arch}" in
        x86);&
        x64)
            echo "    MEN_13MD05-90_SA_0050"
            ;;
        isa);&
        lpc)
            echo "    MEN_13MD05-90_SA_0060"
            ;;
        pci);&
        pcie)
            echo "    MEN_13MD05-90_SA_0070"
            ;;
        vme)
            echo "    MEN_13MD05-90_SA_0080"
            ;;
        *)
            ;;
    esac
}

function cpu_requirement_id {
    local cpu=${1}
    case "${cpu}" in
        f23p)
            echo "    MEN_13MD05-90_SA_1000"
            ;;
        f26)
            echo "    MEN_13MD05-90_SA_1010"
            ;;
        g23)
            echo "    MEN_13MD05-90_SA_1020"
            ;;
        g25a)
            echo "    MEN_13MD05-90_SA_1030"
            ;;
        cb70)
            echo "    MEN_13MD05-90_SA_1040"
            ;;
        a25)
            echo "    MEN_13MD05-90_SA_1050"
            ;;
        *)
            ;;
    esac
}

function os_requirement {
    local os=${1}
    case "${os}" in
        ubuntu)
            echo "    MEN_13MD0590_SWR_2070"
            echo "    MEN_13MD0590_SWR_2071"
            ;;
        centos)
            echo "    MEN_13MD0590_SWR_1981"
            echo "    MEN_13MD0590_SWR_1982"
            ;;
        debian)
            echo "    MEN_13MD0590_SWR_1990"
            ;;
        *)
            ;;
    esac
}

function kernel_requirement {
    local kernel=${1}
    case "${kernel}" in
        lts)
            echo "    New"
            ;;
        latest)
            echo "    New"
            ;;
        *)
            ;;
    esac
}

function arch_requirement {
    local arch=${1}
    case "${arch}" in
        x86);&
        x64)
            echo "    New"
            ;;
        isa);&
        lpc)
            echo "    New"
            ;;
        pci);&
        pcie)
            echo "    New"
            ;;
        vme)
            echo "    New"
            ;;
        *)
            ;;
    esac
}

function cpu_requirement {
    local cpu=${1}
    case "${cpu}" in
        f23p)
            echo "    MEN_13MD0590_SWR_0120"
            ;;
        f26)
            echo "    MEN_13MD0590_SWR_0130"
            ;;
        g23)
            echo "    MEN_13MD0590_SWR_0180"
            ;;
        g25a)
            echo "    MEN_13MD0590_SWR_0190"
            ;;
        cb70)
            echo "    MEN_13MD0590_SWR_0350"
            ;;
        a25)
            echo "    MEN_13MD0590_SWR_0720"
            ;;
        sc24)
            echo "    MEN_13MD0590_SWR_0840"
            ;;
        sc25)
            echo "    MEN_13MD0590_SWR_0850"
            ;;
        sc31)
            echo "    MEN_13MD0590_SWR_0870"
            ;;
        *)
            ;;
    esac
}
