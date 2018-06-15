pragma solidity ^0.4.16;

contract Consorcio {
    // Variables y eventos
    uint public quorumMinimo = 75; // en % de cantidad de socios
    uint public mayoria = 50; // en % de total de votos
    uint public plazoMinVotacion = 259200; // en minutos (86400 minutos = 1 dia)
    Propuesta[] public propuestas;
    uint public cantidadPropuestas;
    mapping (address => uint) public idSocio;
    Socio[] public socios;

    event PropuestaAgregada(uint idPropuesta, string nombre, string descripcion);
    event Votod(uint idPropuesta, bool posicion, address votante);
    event PropuestaTerminada(uint idPropuesta, uint votosAFavor, uint quorum, bool activa);
    event cambioEstado(address socio, bool esSocio);

    struct Propuesta {
        string nombre;
        string descripcion;
        uint fechaEjecucion; // La propuesta no se puede ejecutar antes de esta fecha (en minutos)
        bool realizada;
        bool aprobada;
        uint cantidadVotos;
        uint votosAFavor;
        Voto[] votos;
        mapping (address => bool) yaVotaron;
    }

    struct Socio {
        address socio;
        string nombre;
        uint socioDesde;
    }

    struct Voto {
        bool apoya;
        address votante;
    }

    // Modificador para "solo socios"
    modifier soloSocios {
        require(idSocio[msg.sender] != 0);
        _;
    }

    // Constructor
    constructor() public {
    }

    // Agrega al socio "nombreSocio", con direccion "direccion" al Consorcio
    function agregarSocio(address direccion, string nombre) public {
        uint id = idSocio[direccion];
        if (id == 0) {
            idSocio[direccion] = socios.length;
            id = socios.length++;
        }

        socios[id] = Socio({socio: direccion, socioDesde: now, nombre: nombre});
        emit cambioEstado(direccion, true);
    }

    // Elimina al socio con direccion "direccion" del Consorcio
    function eliminarSocio(address direccion) public {
        require(idSocio[direccion] != 0);

        for (uint i = idSocio[direccion]; i < socios.length-1; i++){
            socios[i] = socios[i+1];
        }
        delete socios[socios.length-1];
        socios.length--;
    }

    // Agregar propuesta "nombrePropuesta" con descripcion "descripcionPropuesta"
    function agregarPropuesta(string nombrePropuesta, string descripcionPropuesta) soloSocios public
        returns (uint idPropuesta)
    {
        idPropuesta = propuestas.length++;
        Propuesta storage p = propuestas[idPropuesta];
        p.nombre = nombrePropuesta;
        p.descripcion = descripcionPropuesta;
        p.fechaEjecucion = now + plazoMinVotacion * 1 minutes;
        p.realizada = false;
        p.aprobada = false;
        p.cantidadVotos = 0;
        emit PropuestaAgregada(idPropuesta, nombrePropuesta, descripcionPropuesta);
        cantidadPropuestas = idPropuesta+1;

        return idPropuesta;
    }

    // Votar por la propuesta "idPropuesta"
    function votar(uint idPropuesta, bool apoyaPropuesta) soloSocios public returns (uint idVoto)
    {
        Propuesta storage p = propuestas[idPropuesta];
        require(!p.yaVotaron[msg.sender] && now < p.fechaEjecucion);
        p.yaVotaron[msg.sender] = true;
        p.cantidadVotos++;
        if (apoyaPropuesta) {
            p.votosAFavor++;
        }

        emit Votod(idPropuesta, apoyaPropuesta, msg.sender);
        return p.cantidadVotos;
    }

    // Ejecutar propuesta "idPropuesta" y realizarla si fue aprobada
    function ejecutarPropuesta(uint idPropuesta) public {
        Propuesta storage p = propuestas[idPropuesta];

        uint cantidadMinimaVotos = (socios.length*quorumMinimo/100)+1;
        require(!p.realizada && now > p.fechaEjecucion && p.cantidadVotos >= cantidadMinimaVotos);

        uint votosMinimosParaAprobar = (cantidadMinimaVotos*mayoria/100)+1;
        if (p.votosAFavor >= votosMinimosParaAprobar) {
            // TODO ejecutar propuesta si es aprobada (depende del tipo de propuesta)

            p.realizada = true;
            p.aprobada = true;
        } else {
            p.aprobada = false;
        }

        emit PropuestaTerminada(idPropuesta, p.votosAFavor, p.cantidadVotos, p.aprobada);
    }

    function getSocios() public view returns (bytes32[10]) {
      bytes32[10] memory nombres;
      for (uint i = 0; i < socios.length; i++) {
        nombres[i] = stringToBytes32(socios[i].nombre);
      }
      return nombres;
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
      bytes memory tempEmptyStringTest = bytes(source);
      if (tempEmptyStringTest.length == 0) {
        return 0x0;
      }

      assembly {
          result := mload(add(source, 32))
      }
    }
}
