#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Directorios organizados
BASE_DIR="/sdcard/DataForge"
ADDRESSES_DIR="$BASE_DIR/fake_addresses"
CARDS_DIR="$BASE_DIR/credit_cards"
IBAN_DIR="$BASE_DIR/iban_codes"
CPF_DIR="$BASE_DIR/cpf_brasil"

# Crear todas las carpetas
mkdir -p "$ADDRESSES_DIR"
mkdir -p "$CARDS_DIR"
mkdir -p "$IBAN_DIR"
mkdir -p "$CPF_DIR"

show_banner() {
    clear
    echo -e "${CYAN}=====================================================================================================${NC}"
    echo -e "${CYAN}               
██████╗░░█████╗░████████╗░█████╗░  ███████╗░█████╗░██████╗░░██████╗░███████╗  ██████╗░███████╗████████╗░█████╗░
██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗  ██╔════╝██╔══██╗██╔══██╗██╔════╝░██╔════╝  ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗
██║░░██║███████║░░░██║░░░███████║  █████╗░░██║░░██║██████╔╝██║░░██╗░█████╗░░  ██████╦╝█████╗░░░░░██║░░░███████║
██║░░██║██╔══██║░░░██║░░░██╔══██║  ██╔══╝░░██║░░██║██╔══██╗██║░░╚██╗██╔══╝░░  ██╔══██╗██╔══╝░░░░░██║░░░██╔══██║
██████╔╝██║░░██║░░░██║░░░██║░░██║  ██║░░░░░╚█████╔╝██║░░██║╚██████╔╝███████╗  ██████╦╝███████╗░░░██║░░░██║░░██║
╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝  ╚═╝░░░░░░╚════╝░╚═╝░░╚═╝░╚═════╝░╚══════╝  ╚═════╝░╚══════╝░░░╚═╝░░░╚═╝░░╚═╝               ${NC}"
    echo -e "${CYAN}
                         █▀ █▀▀ █░█ █▀█ █▀█ █░░   █ █░░ █░█ █▀▄▀█ █ █▄░█ ▄▀█ ▀█▀ █▄█
                         ▄█ █▄▄ █▀█ █▄█ █▄█ █▄▄   █ █▄▄ █▄█ █░▀░█ █ █░▀█ █▀█ ░█░ ░█░${NC}"
    echo -e "${CYAN}=====================================================================================================${NC}"
    echo -e "${GREEN}                                               🅜🅐🅓🅔 🅑🅨 🅘🅓🅔🅥➒➋                      ${NC}"
    echo -e "${CYAN}=====================================================================================================${NC}"
}

generate_coordinates() {
    local lat_min=$1
    local lat_max=$2
    local lon_min=$3
    local lon_max=$4
    
    lat=$(awk -v min="$lat_min" -v max="$lat_max" 'BEGIN{srand(); print min+rand()*(max-min)}')
    lon=$(awk -v min="$lon_min" -v max="$lon_max" 'BEGIN{srand(); print min+rand()*(max-min)}')
    lat=$(printf "%.6f" "$lat")
    lon=$(printf "%.6f" "$lon")
}

generate_names() {
    local nombres=("Carlos" "Maria" "Jose" "Ana" "Luis" "Carmen" "Antonio" "Rosa" "Manuel" "Elena" "Francisco" "Isabel" "David" "Patricia" "Miguel" "Laura" "Rafael" "Sofia" "Diego" "Lucia")
    local apellidos=("Garcia" "Rodriguez" "Martinez" "Lopez" "Gonzalez" "Perez" "Sanchez" "Ramirez" "Cruz" "Torres" "Flores" "Rivera" "Gomez" "Diaz" "Reyes" "Morales" "Jimenez" "Alvarez" "Ruiz" "Hernandez")
    
    local nombre_idx=$((RANDOM % ${#nombres[@]}))
    local apellido1_idx=$((RANDOM % ${#apellidos[@]}))
    local apellido2_idx=$((RANDOM % ${#apellidos[@]}))
    
    nombre_completo="${nombres[$nombre_idx]} ${apellidos[$apellido1_idx]} ${apellidos[$apellido2_idx]}"
}

# Generador de tarjetas estilo Namso Gen
generate_credit_card() {
    local bin=$1
    local cantidad=$2
    
    echo -e "${GREEN}=== GENERADOR DE TARJETAS DE CREDITO ===${NC}"
    echo -e "${PURPLE}MADE BY IDEV92${NC}"
    echo ""
    
    local filename="$CARDS_DIR/cards_${bin}_$(date +%Y%m%d_%H%M%S).txt"
    echo "=== DATAFORGE - TARJETAS GENERADAS ===" > "$filename"
    echo "BIN: $bin" >> "$filename"
    echo "Cantidad: $cantidad" >> "$filename"
    echo "Generado: $(date '+%Y-%m-%d %H:%M:%S')" >> "$filename"
    echo "MADE BY IDEV92" >> "$filename"
    echo "=======================================" >> "$filename"
    echo "" >> "$filename"
    
    for i in $(seq 1 $cantidad); do
        # Generar los últimos 10 dígitos
        local resto=""
        for j in $(seq 1 10); do
            resto="${resto}$((RANDOM % 10))"
        done
        
        # Crear número completo
        local numero_completo="${bin}${resto}"
        
        # Calcular dígito de verificación Luhn
        local suma=0
        local alternar=false
        local longitud=${#numero_completo}
        
        for ((k=longitud-1; k>=0; k--)); do
            local digito=${numero_completo:$k:1}
            if [ "$alternar" = true ]; then
                digito=$((digito * 2))
                if [ $digito -gt 9 ]; then
                    digito=$((digito - 9))
                fi
            fi
            suma=$((suma + digito))
            if [ "$alternar" = true ]; then
                alternar=false
            else
                alternar=true
            fi
        done
        
        local checksum=$(((10 - (suma % 10)) % 10))
        local tarjeta_final="${numero_completo:0:15}${checksum}"
        
        # Generar fecha de expiración
        local mes=$(printf "%02d" $((RANDOM % 12 + 1)))
        local ano=$((RANDOM % 8 + 24))  # 2024-2031
        
        # Generar CVV
        local cvv=$(printf "%03d" $((RANDOM % 999 + 1)))
        
        echo -e "${YELLOW}$i. $tarjeta_final|$mes/$ano|$cvv${NC}"
        echo "$i. $tarjeta_final|$mes/$ano|$cvv" >> "$filename"
    done
    
    echo ""
    echo -e "${GREEN}Tarjetas guardadas en:${NC}"
    echo -e "${CYAN}$filename${NC}"
    echo -e "${PURPLE}MADE BY IDEV92${NC}"
}

# Generador de IBAN
generate_iban() {
    local pais=$1
    local cantidad=$2
    
    echo -e "${GREEN}=== GENERADOR DE IBAN ===${NC}"
    echo -e "${PURPLE}MADE BY IDEV92${NC}"
    echo ""
    
    local filename="$IBAN_DIR/iban_${pais}_$(date +%Y%m%d_%H%M%S).txt"
    echo "=== DATAFORGE - IBAN GENERADOS ===" > "$filename"
    echo "Pais: $pais" >> "$filename"
    echo "Cantidad: $cantidad" >> "$filename"
    echo "Generado: $(date '+%Y-%m-%d %H:%M:%S')" >> "$filename"
    echo "MADE BY IDEV92" >> "$filename"
    echo "===================================" >> "$filename"
    echo "" >> "$filename"
    
    for i in $(seq 1 $cantidad); do
        local iban=""
        case $pais in
            "ES") # España
                local banco=$(printf "%04d" $((RANDOM % 9999)))
                local sucursal=$(printf "%04d" $((RANDOM % 9999)))
                local dc=$(printf "%02d" $((RANDOM % 99)))
                local cuenta=$(printf "%010d" $((RANDOM % 9999999999)))
                iban="ES${dc}${banco}${sucursal}${dc}${cuenta}"
                ;;
            "FR") # Francia
                local banco=$(printf "%05d" $((RANDOM % 99999)))
                local sucursal=$(printf "%05d" $((RANDOM % 99999)))
                local cuenta=$(printf "%011d" $((RANDOM % 99999999999)))
                local check=$(printf "%02d" $((RANDOM % 99)))
                iban="FR${check}${banco}${sucursal}${cuenta}${check}"
                ;;
            "DE") # Alemania
                local banco=$(printf "%08d" $((RANDOM % 99999999)))
                local cuenta=$(printf "%010d" $((RANDOM % 9999999999)))
                local check=$(printf "%02d" $((RANDOM % 99)))
                iban="DE${check}${banco}${cuenta}"
                ;;
            "IT") # Italia
                local check=$(printf "%02d" $((RANDOM % 99)))
                local cin="X"
                local abi=$(printf "%05d" $((RANDOM % 99999)))
                local cab=$(printf "%05d" $((RANDOM % 99999)))
                local cuenta=$(printf "%012d" $((RANDOM % 999999999999)))
                iban="IT${check}${cin}${abi}${cab}${cuenta}"
                ;;
            "GB") # Reino Unido
                local banco="ABNA"
                local sucursal=$(printf "%06d" $((RANDOM % 999999)))
                local cuenta=$(printf "%08d" $((RANDOM % 99999999)))
                local check=$(printf "%02d" $((RANDOM % 99)))
                iban="GB${check}${banco}${sucursal}${cuenta}"
                ;;
            "NL") # Holanda
                local banco="ABNA"
                local cuenta=$(printf "%010d" $((RANDOM % 9999999999)))
                local check=$(printf "%02d" $((RANDOM % 99)))
                iban="NL${check}${banco}${cuenta}"
                ;;
            "PT") # Portugal
                local banco=$(printf "%04d" $((RANDOM % 9999)))
                local sucursal=$(printf "%04d" $((RANDOM % 9999)))
                local cuenta=$(printf "%011d" $((RANDOM % 99999999999)))
                local check=$(printf "%02d" $((RANDOM % 99)))
                iban="PT${check}${banco}${sucursal}${cuenta}${check}"
                ;;
            "BE") # Bélgica
                local banco=$(printf "%03d" $((RANDOM % 999)))
                local cuenta=$(printf "%07d" $((RANDOM % 9999999)))
                local check=$(printf "%02d" $((RANDOM % 99)))
                iban="BE${check}${banco}${cuenta}${check}"
                ;;
        esac
        
        echo -e "${YELLOW}$i. $iban${NC}"
        echo "$i. $iban" >> "$filename"
    done
    
    echo ""
    echo -e "${GREEN}IBAN guardados en:${NC}"
    echo -e "${CYAN}$filename${NC}"
    echo -e "${PURPLE}MADE BY IDEV92${NC}"
}

# Generador de CPF brasileño válido
generate_cpf() {
    local cantidad=$1
    
    echo -e "${GREEN}=== GENERADOR DE CPF BRASIL ===${NC}"
    echo -e "${PURPLE}MADE BY IDEV92${NC}"
    echo ""
    
    local filename="$CPF_DIR/cpf_brasil_$(date +%Y%m%d_%H%M%S).txt"
    echo "=== DATAFORGE - CPF BRASIL GENERADOS ===" > "$filename"
    echo "Cantidad: $cantidad" >> "$filename"
    echo "Generado: $(date '+%Y-%m-%d %H:%M:%S')" >> "$filename"
    echo "MADE BY IDEV92" >> "$filename"
    echo "=========================================" >> "$filename"
    echo "" >> "$filename"
    
    for i in $(seq 1 $cantidad); do
        # Generar 9 primeros dígitos
        local cpf=""
        for j in $(seq 1 9); do
            cpf="${cpf}$((RANDOM % 10))"
        done
        
        # Calcular primer dígito verificador
        local suma=0
        for j in $(seq 1 9); do
            local digito=${cpf:$((j-1)):1}
            suma=$((suma + digito * (11 - j)))
        done
        local resto=$((suma % 11))
        local dv1=0
        if [ $resto -ge 2 ]; then
            dv1=$((11 - resto))
        fi
        
        # Calcular segundo dígito verificador
        cpf="${cpf}${dv1}"
        suma=0
        for j in $(seq 1 10); do
            local digito=${cpf:$((j-1)):1}
            suma=$((suma + digito * (12 - j)))
        done
        resto=$((suma % 11))
        local dv2=0
        if [ $resto -ge 2 ]; then
            dv2=$((11 - resto))
        fi
        
        cpf="${cpf}${dv2}"
        
        # Formatear CPF
        local cpf_formatado="${cpf:0:3}.${cpf:3:3}.${cpf:6:3}-${cpf:9:2}"
        
        echo -e "${YELLOW}$i. $cpf_formatado${NC}"
        echo "$i. $cpf_formatado" >> "$filename"
    done
    
    echo ""
    echo -e "${GREEN}CPF guardados en:${NC}"
    echo -e "${CYAN}$filename${NC}"
    echo -e "${PURPLE}MADE BY IDEV92${NC}"
}

generate_location() {
    local country=$1
    local country_name=$2
    
    generate_names
    local edad=$((RANDOM % 60 + 18))
    local telefono=""
    local codigo_postal=""
    local direccion=""
    local ciudad=""
    local estado=""
    
    case $country in
        "argentina")
            generate_coordinates -55.0 -21.8 -73.6 -53.6
            local ciudades=("Buenos Aires" "Cordoba" "Rosario" "Mendoza" "La Plata")
            local barrios=("Palermo" "Recoleta" "Villa Crespo" "San Telmo" "Belgrano")
            local calles=("Av. Corrientes" "Av. Santa Fe" "Av. Rivadavia" "Calle Florida" "Av. 9 de Julio")
            ciudad="${ciudades[$((RANDOM % ${#ciudades[@]}))]}"
            local barrio="${barrios[$((RANDOM % ${#barrios[@]}))]}"
            local calle="${calles[$((RANDOM % ${#calles[@]}))]}"
            local numero=$((RANDOM % 9999 + 1))
            direccion="$calle $numero, $barrio"
            codigo_postal="C$(printf "%04d" $((RANDOM % 9999 + 1000)))XXX"
            telefono="+54 11 $(printf "%04d" $((RANDOM % 9999)))-$(printf "%04d" $((RANDOM % 9999)))"
            estado="Buenos Aires"
            ;;
        "brasil")
            generate_coordinates -33.7 5.3 -73.9 -28.8
            local ciudades=("Sao Paulo" "Rio de Janeiro" "Brasilia" "Salvador" "Fortaleza")
            local bairros=("Copacabana" "Ipanema" "Vila Olimpia" "Moema" "Leblon")
            local ruas=("Rua das Flores" "Av. Paulista" "Rua Augusta" "Av. Atlantica" "Rua Oscar Freire")
            ciudad="${ciudades[$((RANDOM % ${#ciudades[@]}))]}"
            local bairro="${bairros[$((RANDOM % ${#bairros[@]}))]}"
            local rua="${ruas[$((RANDOM % ${#ruas[@]}))]}"
            local numero=$((RANDOM % 9999 + 1))
            direccion="$rua, $numero - $bairro"
            codigo_postal="$(printf "%05d" $((RANDOM % 99999 + 10000)))-$(printf "%03d" $((RANDOM % 999)))"
            telefono="+55 $(printf "%02d" $((RANDOM % 89 + 11))) $(printf "%d" $((RANDOM % 8 + 2)))$(printf "%04d" $((RANDOM % 9999)))-$(printf "%04d" $((RANDOM % 9999)))"
            estado="Sao Paulo"
            ;;
        "mexico")
            generate_coordinates 14.5 32.7 -118.4 -86.7
            local ciudades=("Ciudad de Mexico" "Guadalajara" "Monterrey" "Puebla" "Tijuana")
            local colonias=("Roma Norte" "Condesa" "Polanco" "Santa Fe" "Del Valle")
            local calles=("Av. Insurgentes" "Av. Reforma" "Eje Central" "Av. Universidad" "Calle Madero")
            ciudad="${ciudades[$((RANDOM % ${#ciudades[@]}))]}"
            local colonia="${colonias[$((RANDOM % ${#colonias[@]}))]}"
            local calle="${calles[$((RANDOM % ${#calles[@]}))]}"
            local numero=$((RANDOM % 999 + 1))
            direccion="$calle #$numero, Col. $colonia"
            codigo_postal="$(printf "%05d" $((RANDOM % 99999 + 10000)))"
            telefono="+52 55 $(printf "%04d" $((RANDOM % 9999))) $(printf "%04d" $((RANDOM % 9999)))"
            estado="Ciudad de Mexico"
            ;;
        "colombia")
            generate_coordinates -4.2 12.5 -81.7 -66.9
            local ciudades=("Bogota" "Medellin" "Cali" "Barranquilla" "Cartagena")
            local localidades=("Chapinero" "Zona Rosa" "Centro" "Norte" "Sur")
            local calles=("Carrera 7" "Calle 72" "Av. Caracas" "Carrera 15" "Calle 26")
            ciudad="${ciudades[$((RANDOM % ${#ciudades[@]}))]}"
            local localidad="${localidades[$((RANDOM % ${#localidades[@]}))]}"
            local calle="${calles[$((RANDOM % ${#calles[@]}))]}"
            local numero=$((RANDOM % 99 + 1))-$((RANDOM % 99 + 1))
            direccion="$calle #$numero, $localidad"
            codigo_postal="$(printf "%06d" $((RANDOM % 999999 + 100000)))"
            telefono="+57 $(printf "%03d" $((RANDOM % 899 + 100))) $(printf "%07d" $((RANDOM % 9999999)))"
            estado="Cundinamarca"
            ;;
        "chile")
            generate_coordinates -56.0 -17.5 -109.4 -66.4
            local ciudades=("Santiago" "Valparaiso" "Concepcion" "Antofagasta" "Vina del Mar")
            local comunas=("Las Condes" "Providencia" "Vitacura" "La Reina" "Nunoa")
            local calles=("Av. Libertador" "Calle Huerfanos" "Av. Providencia" "Calle Ahumada" "Av. Las Condes")
            ciudad="${ciudades[$((RANDOM % ${#ciudades[@]}))]}"
            local comuna="${comunas[$((RANDOM % ${#comunas[@]}))]}"
            local calle="${calles[$((RANDOM % ${#calles[@]}))]}"
            local numero=$((RANDOM % 9999 + 1))
            direccion="$calle $numero, $comuna"
            codigo_postal="$(printf "%07d" $((RANDOM % 9999999 + 1000000)))"
            telefono="+56 $(printf "%d" $((RANDOM % 8 + 2))) $(printf "%04d" $((RANDOM % 9999))) $(printf "%04d" $((RANDOM % 9999)))"
            estado="Region Metropolitana"
            ;;
        "peru")
            generate_coordinates -18.3 -0.0 -81.3 -68.7
            local ciudades=("Lima" "Arequipa" "Trujillo" "Chiclayo" "Huancayo")
            local distritos=("Miraflores" "San Isidro" "Surco" "La Molina" "Barranco")
            local calles=("Av. Larco" "Av. Arequipa" "Jiron de la Union" "Av. Brasil" "Av. Salaverry")
            ciudad="${ciudades[$((RANDOM % ${#ciudades[@]}))]}"
            local distrito="${distritos[$((RANDOM % ${#distritos[@]}))]}"
            local calle="${calles[$((RANDOM % ${#calles[@]}))]}"
            local numero=$((RANDOM % 9999 + 1))
            direccion="$calle $numero, $distrito"
            codigo_postal="$(printf "%05d" $((RANDOM % 99999 + 10000)))"
            telefono="+51 1 $(printf "%03d" $((RANDOM % 899 + 100))) $(printf "%04d" $((RANDOM % 9999)))"
            estado="Lima"
            ;;
        "venezuela")
            generate_coordinates 0.6 12.2 -73.4 -59.8
            local ciudades=("Caracas" "Maracaibo" "Valencia" "Barquisimeto" "Maracay")
            local municipios=("Chacao" "Baruta" "El Hatillo" "Sucre" "Libertador")
            local calles=("Av. Francisco de Miranda" "Av. Libertador" "Av. Principal" "Calle Real" "Av. Casanova")
            ciudad="${ciudades[$((RANDOM % ${#ciudades[@]}))]}"
            local municipio="${municipios[$((RANDOM % ${#municipios[@]}))]}"
            local calle="${calles[$((RANDOM % ${#calles[@]}))]}"
            local numero=$((RANDOM % 999 + 1))
            direccion="$calle, Casa $numero, $municipio"
            codigo_postal="$(printf "%04d" $((RANDOM % 9999 + 1000)))"
            telefono="+58 $(printf "%03d" $((RANDOM % 899 + 100))) $(printf "%07d" $((RANDOM % 9999999)))"
            estado="Distrito Capital"
            ;;
        "ecuador")
            generate_coordinates -5.0 1.7 -92.0 -75.2
            local ciudades=("Quito" "Guayaquil" "Cuenca" "Santo Domingo" "Machala")
            local sectores=("La Mariscal" "Carolina" "Cumbaya" "Valle de los Chillos" "Tumbaco")
            local calles=("Av. Amazonas" "Av. 6 de Diciembre" "Av. Republica" "Av. Shyris" "Calle Venezuela")
            ciudad="${ciudades[$((RANDOM % ${#ciudades[@]}))]}"
            local sector="${sectores[$((RANDOM % ${#sectores[@]}))]}"
            local calle="${calles[$((RANDOM % ${#calles[@]}))]}"
            local numero=$((RANDOM % 999 + 1))-$((RANDOM % 99 + 1))
            direccion="$calle $numero, $sector"
            codigo_postal="$(printf "%06d" $((RANDOM % 999999 + 100000)))"
            telefono="+593 $(printf "%d" $((RANDOM % 8 + 2))) $(printf "%07d" $((RANDOM % 9999999)))"
            estado="Pichincha"
            ;;
        "espana")
            generate_coordinates 35.2 43.8 -9.3 3.3
            local ciudades=("Madrid" "Barcelona" "Valencia" "Sevilla" "Bilbao")
            local barrios=("Salamanca" "Chamberi" "Retiro" "Centro" "Malasana")
            local calles=("Calle Gran Via" "Calle Alcala" "Paseo de la Castellana" "Calle Serrano" "Calle Preciados")
            ciudad="${ciudades[$((RANDOM % ${#ciudades[@]}))]}"
            local barrio="${barrios[$((RANDOM % ${#barrios[@]}))]}"
            local calle="${calles[$((RANDOM % ${#calles[@]}))]}"
            local numero=$((RANDOM % 999 + 1))
            direccion="$calle, $numero, $barrio"
            codigo_postal="$(printf "%05d" $((RANDOM % 99999 + 10000)))"
            telefono="+34 $(printf "%03d" $((RANDOM % 899 + 600))) $(printf "%06d" $((RANDOM % 999999)))"
            estado="Madrid"
            ;;
        "francia")
            generate_coordinates 41.3 51.1 -5.1 9.6
            local ciudades=("Paris" "Lyon" "Marseille" "Toulouse" "Nice")
            local arrondissements=("1er arr." "2e arr." "3e arr." "4e arr." "5e arr.")
            local rues=("Rue de Rivoli" "Champs-Elysees" "Rue Saint-Honore" "Boulevard Saint-Germain" "Rue de la Paix")
            ciudad="${ciudades[$((RANDOM % ${#ciudades[@]}))]}"
            local arr="${arrondissements[$((RANDOM % ${#arrondissements[@]}))]}"
            local rue="${rues[$((RANDOM % ${#rues[@]}))]}"
            local numero=$((RANDOM % 999 + 1))
            direccion="$numero $rue, $arr"
            codigo_postal="$(printf "%05d" $((RANDOM % 89999 + 10000)))"
            telefono="+33 $(printf "%d" $((RANDOM % 8 + 1))) $(printf "%08d" $((RANDOM % 99999999)))"
            estado="Ile-de-France"
            ;;
        "italia")
            generate_coordinates 35.5 47.1 6.6 18.5
            local ciudades=("Roma" "Milano" "Napoli" "Torino" "Firenze")
            local quartieri=("Centro" "Trastevere" "Prati" "Testaccio" "Monti")
            local vie=("Via del Corso" "Via Nazionale" "Via Veneto" "Via Appia" "Via Flaminia")
            ciudad="${ciudades[$((RANDOM % ${#ciudades[@]}))]}"
            local quartiere="${quartieri[$((RANDOM % ${#quartieri[@]}))]}"
            local via="${vie[$((RANDOM % ${#vie[@]}))]}"
            local numero=$((RANDOM % 999 + 1))
            direccion="$via, $numero, $quartiere"
            codigo_postal="$(printf "%05d" $((RANDOM % 99999 + 10000)))"
            telefono="+39 $(printf "%03d" $((RANDOM % 899 + 100))) $(printf "%07d" $((RANDOM % 9999999)))"
            estado="Lazio"
            ;;
        "alemania")
            generate_coordinates 47.3 55.1 5.9 15.0
            local ciudades=("Berlin" "Munich" "Hamburg" "Koln" "Frankfurt")
            local bezirke=("Mitte" "Charlottenburg" "Kreuzberg" "Prenzlauer Berg" "Schoneberg")
            local strassen=("Unter den Linden" "Kurfurstendamm" "Alexanderplatz" "Potsdamer Platz" "Friedrichstrasse")
            ciudad="${ciudades[$((RANDOM % ${#ciudades[@]}))]}"
            local bezirk="${bezirke[$((RANDOM % ${#bezirke[@]}))]}"
            local strasse="${strassen[$((RANDOM % ${#strassen[@]}))]}"
            local numero=$((RANDOM % 999 + 1))
            direccion="$strasse $numero, $bezirk"
            codigo_postal="$(printf "%05d" $((RANDOM % 99999 + 10000)))"
            telefono="+49 $(printf "%03d" $((RANDOM % 899 + 100))) $(printf "%08d" $((RANDOM % 99999999)))"
            estado="Berlin"
            ;;
        *)
            echo -e "${RED}Pais no reconocido${NC}"
            return 1
            ;;
    esac
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local accuracy=$((RANDOM % 50 + 1))
    local altitude=$((RANDOM % 3000 - 500))
    local piso=$((RANDOM % 20 + 1))
    local apartamento=$(printf "%c" $((RANDOM % 26 + 65)))
    local email=$(echo "$nombre_completo" | tr '[:upper:]' '[:lower:]' | tr ' ' '.')
    local dominios=("gmail.com" "hotmail.com" "yahoo.com" "outlook.com")
    local dominio="${dominios[$((RANDOM % ${#dominios[@]}))]}"
    email="$email@$dominio"
    
    echo -e "${GREEN}=== DIRECCION COMPLETA GENERADA ===${NC}"
    echo -e "${PURPLE}MADE BY IDEV92${NC}"
    echo -e "${YELLOW}Pais: $country_name${NC}"
    echo -e "${YELLOW}Nombre: $nombre_completo${NC}"
    echo -e "${YELLOW}Edad: $edad anos${NC}"
    echo -e "${YELLOW}Telefono: $telefono${NC}"
    echo -e "${YELLOW}Email: $email${NC}"
    echo -e "${YELLOW}Direccion: $direccion${NC}"
    echo -e "${YELLOW}Ciudad: $ciudad${NC}"
    echo -e "${YELLOW}Estado: $estado${NC}"
    echo -e "${YELLOW}Codigo Postal: $codigo_postal${NC}"
    echo -e "${YELLOW}Piso: Piso $piso, Apt $apartamento${NC}"
    echo -e "${YELLOW}Coordenadas: $lat, $lon${NC}"
    echo -e "${YELLOW}Precision: ${accuracy}m${NC}"
    echo -e "${YELLOW}Altitud: ${altitude}m${NC}"
    echo -e "${YELLOW}Timestamp: $timestamp${NC}"
    
    local filename="$ADDRESSES_DIR/address_${country}_$(date +%Y%m%d_%H%M%S).txt"
    echo "=== DATAFORGE - DIRECCION COMPLETA ===" > "$filename"
    echo "Pais: $country_name" >> "$filename"
    echo "Nombre Completo: $nombre_completo" >> "$filename"
    echo "Edad: $edad anos" >> "$filename"
    echo "Telefono: $telefono" >> "$filename"
    echo "Email: $email" >> "$filename"
    echo "=======================================" >> "$filename"
    echo "=== DIRECCION COMPLETA ===" >> "$filename"
    echo "Direccion: $direccion" >> "$filename"
    echo "Ciudad: $ciudad" >> "$filename"
    echo "Estado: $estado" >> "$filename"
    echo "Codigo Postal: $codigo_postal" >> "$filename"
    echo "Piso: Piso $piso, Apartamento $apartamento" >> "$filename"
    echo "==========================" >> "$filename"
    echo "=== COORDENADAS GPS ===" >> "$filename"
    echo "Latitud: $lat" >> "$filename"
    echo "Longitud: $lon" >> "$filename"
    echo "Precision: ${accuracy}m" >> "$filename"
    echo "Altitud: ${altitude}m" >> "$filename"
    echo "Timestamp: $timestamp" >> "$filename"
    echo "Google Maps: https://maps.google.com/?q=$lat,$lon" >> "$filename"
    echo "=======================" >> "$filename"
    echo "MADE BY IDEV92" >> "$filename"
    
    echo ""
    echo -e "${GREEN}Direccion guardada en:${NC}"
    echo -e "${CYAN}$filename${NC}"
    echo -e "${PURPLE}MADE BY IDEV92${NC}"
}

show_latin_menu() {
    echo -e "${PURPLE}=== PAISES LATINOAMERICANOS ===${NC}"
    echo "1. Argentina    2. Brasil       3. Mexico"
    echo "4. Colombia     5. Chile        6. Peru"
    echo "7. Venezuela    8. Ecuador      9. Volver"
    echo ""
    echo -e "${PURPLE}MADE BY IDEV92${NC}"
}

show_europe_menu() {
    echo -e "${BLUE}=== PAISES EUROPEOS ===${NC}"
    echo "1. Espana       2. Francia      3. Italia"
    echo "4. Alemania     5. Volver"
    echo ""
    echo -e "${PURPLE}MADE BY IDEV92${NC}"
}

process_latin_selection() {
    case $1 in
        1) generate_location "argentina" "Argentina" ;;
        2) generate_location "brasil" "Brasil" ;;
        3) generate_location "mexico" "Mexico" ;;
        4) generate_location "colombia" "Colombia" ;;
        5) generate_location "chile" "Chile" ;;
        6) generate_location "peru" "Peru" ;;
        7) generate_location "venezuela" "Venezuela" ;;
        8) generate_location "ecuador" "Ecuador" ;;
        9) return 0 ;;
        *) echo -e "${RED}Opcion invalida${NC}" ;;
    esac
}

process_europe_selection() {
    case $1 in
        1) generate_location "espana" "Espana" ;;
        2) generate_location "francia" "Francia" ;;
        3) generate_location "italia" "Italia" ;;
        4) generate_location "alemania" "Alemania" ;;
        5) return 0 ;;
        *) echo -e "${RED}Opcion invalida${NC}" ;;
    esac
}

show_files_menu() {
    show_banner
    echo -e "${CYAN}=== ARCHIVOS GENERADOS ===${NC}"
    echo -e "${PURPLE}MADE BY IDEV92${NC}"
    echo ""
    echo "Carpetas organizadas:"
    echo -e "${YELLOW}1. Direcciones:${NC} $ADDRESSES_DIR"
    echo -e "${YELLOW}2. Tarjetas:${NC} $CARDS_DIR"
    echo -e "${YELLOW}3. IBAN:${NC} $IBAN_DIR"
    echo -e "${YELLOW}4. CPF Brasil:${NC} $CPF_DIR"
    echo ""
    
    echo -e "${GREEN}Estadisticas:${NC}"
    echo -e "${CYAN}Direcciones: $(ls "$ADDRESSES_DIR" 2>/dev/null | wc -l) archivos${NC}"
    echo -e "${CYAN}Tarjetas: $(ls "$CARDS_DIR" 2>/dev/null | wc -l) archivos${NC}"
    echo -e "${CYAN}IBAN: $(ls "$IBAN_DIR" 2>/dev/null | wc -l) archivos${NC}"
    echo -e "${CYAN}CPF: $(ls "$CPF_DIR" 2>/dev/null | wc -l) archivos${NC}"
    echo ""
    echo -e "${PURPLE}MADE BY IDEV92${NC}"
    echo ""
    echo -e "${CYAN}Presiona Enter para continuar...${NC}"
    read dummy
}

main_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}=== MENU PRINCIPAL ===${NC}"
        echo "1. Paises Latinoamericanos"
        echo "2. Paises Europeos"
        echo "3. Generador de Tarjetas"
        echo "4. Generador de IBAN"
        echo "5. Generador de CPF Brasil"
        echo "6. Ver Archivos Generados"
        echo "7. Salir"
        echo ""
        echo -e "${PURPLE}MADE BY IDEV92${NC}"
        echo ""
        echo -e "${YELLOW}Selecciona una opcion:${NC}"
        read option
        
        case $option in
            1)
                while true; do
                    show_banner
                    show_latin_menu
                    echo ""
                    echo -e "${YELLOW}Selecciona un pais:${NC}"
                    read country_option
                    
                    if [ "$country_option" = "9" ]; then
                        break
                    fi
                    
                    process_latin_selection "$country_option"
                    
                    if [ "$country_option" != "9" ]; then
                        echo ""
                        echo -e "${CYAN}Presiona Enter para continuar...${NC}"
                        read dummy
                    fi
                done
                ;;
            2)
                while true; do
                    show_banner
                    show_europe_menu
                    echo ""
                    echo -e "${YELLOW}Selecciona un pais:${NC}"
                    read country_option
                    
                    if [ "$country_option" = "5" ]; then
                        break
                    fi
                    
                    process_europe_selection "$country_option"
                    
                    if [ "$country_option" != "5" ]; then
                        echo ""
                        echo -e "${CYAN}Presiona Enter para continuar...${NC}"
                        read dummy
                    fi
                done
                ;;
            3)
                show_banner
                echo -e "${CYAN}=== GENERADOR DE TARJETAS ===${NC}"
                echo -e "${PURPLE}MADE BY IDEV92${NC}"
                echo ""
                echo "BINs disponibles:"
                echo "1. 4532 (Visa)"
                echo "2. 5555 (Mastercard)"
                echo "3. 3782 (American Express)"
                echo "4. 6011 (Discover)"
                echo "5. Personalizado"
                echo ""
                echo -e "${YELLOW}Selecciona un BIN:${NC}"
                read bin_option
                
                case $bin_option in
                    1) bin="4532" ;;
                    2) bin="5555" ;;
                    3) bin="3782" ;;
                    4) bin="6011" ;;
                    5) 
                        echo -e "${YELLOW}Ingresa el BIN personalizado (4-6 digitos):${NC}"
                        read bin
                        ;;
                    *) 
                        echo -e "${RED}Opcion invalida${NC}"
                        sleep 1
                        continue
                        ;;
                esac
                
                echo -e "${YELLOW}Cuantas tarjetas quieres generar (1-50):${NC}"
                read cantidad
                
                if ! echo "$cantidad" | grep -q '^[0-9]\+$' || [ "$cantidad" -lt 1 ] || [ "$cantidad" -gt 50 ]; then
                    echo -e "${RED}Cantidad invalida${NC}"
                    sleep 2
                    continue
                fi
                
                generate_credit_card "$bin" "$cantidad"
                echo ""
                echo -e "${CYAN}Presiona Enter para continuar...${NC}"
                read dummy
                ;;
            4)
                show_banner
                echo -e "${CYAN}=== GENERADOR DE IBAN ===${NC}"
                echo -e "${PURPLE}MADE BY IDEV92${NC}"
                echo ""
                echo "Paises disponibles:"
                echo "1. ES (Espana)     2. FR (Francia)"
                echo "3. DE (Alemania)   4. IT (Italia)"
                echo "5. GB (Reino Unido) 6. NL (Holanda)"
                echo "7. PT (Portugal)   8. BE (Belgica)"
                echo ""
                echo -e "${YELLOW}Selecciona un pais:${NC}"
                read pais_option
                
                case $pais_option in
                    1) pais="ES" ;;
                    2) pais="FR" ;;
                    3) pais="DE" ;;
                    4) pais="IT" ;;
                    5) pais="GB" ;;
                    6) pais="NL" ;;
                    7) pais="PT" ;;
                    8) pais="BE" ;;
                    *) 
                        echo -e "${RED}Opcion invalida${NC}"
                        sleep 1
                        continue
                        ;;
                esac
                
                echo -e "${YELLOW}Cuantos IBAN quieres generar (1-30):${NC}"
                read cantidad
                
                if ! echo "$cantidad" | grep -q '^[0-9]\+$' || [ "$cantidad" -lt 1 ] || [ "$cantidad" -gt 30 ]; then
                    echo -e "${RED}Cantidad invalida${NC}"
                    sleep 2
                    continue
                fi
                
                generate_iban "$pais" "$cantidad"
                echo ""
                echo -e "${CYAN}Presiona Enter para continuar...${NC}"
                read dummy
                ;;
            5)
                show_banner
                echo -e "${CYAN}=== GENERADOR DE CPF BRASIL ===${NC}"
                echo -e "${PURPLE}MADE BY IDEV92${NC}"
                echo ""
                echo -e "${YELLOW}Cuantos CPF quieres generar (1-30):${NC}"
                read cantidad
                
                if ! echo "$cantidad" | grep -q '^[0-9]\+$' || [ "$cantidad" -lt 1 ] || [ "$cantidad" -gt 30 ]; then
                    echo -e "${RED}Cantidad invalida${NC}"
                    sleep 2
                    continue
                fi
                
                generate_cpf "$cantidad"
                echo ""
                echo -e "${CYAN}Presiona Enter para continuar...${NC}"
                read dummy
                ;;
            6)
                show_files_menu
                ;;
            7)
                echo -e "${GREEN}Hasta luego!${NC}"
                echo -e "${PURPLE}MADE BY IDEV92${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opcion invalida${NC}"
                sleep 1
                ;;
        esac
    done
}

if [ ! -d "/sdcard" ]; then
    echo -e "${RED}Error: Este script esta disenado para Termux${NC}"
    echo -e "${PURPLE}MADE BY IDEV92${NC}"
    exit 1
fi

main_menu