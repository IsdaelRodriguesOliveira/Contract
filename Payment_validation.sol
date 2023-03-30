// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
contract Payment_validation{
    /*struct Usuarios{
        //numero de transacoes do usuario
        uint num_transacoes;
        //estado da transacao atual
        uint8 estado_transacao;
    }*/
    
    struct Data_user{
        //valor depositado no contrato
        uint256 amount_received;
        //numero do boleto a ser pago
        uint256 ticket_number;
        //estado do pagamento: true (valor depositado), false (valor pendente)
        bool payment_status;
    }

    //rede das transacoes realizadas
    //mapping(address => Usuarios) rede_tramsacoes;
    //rede das transacoes em espera
    mapping(address => Data_user) users;
    address private owner;
    constructor(){
        owner = msg.sender;
    }
    function deposit(uint256 _valor_esperado, uint256 _ticket_number) external payable returns(string memory _resultado){
        require(users[msg.sender].payment_status == false && _valor_esperado == msg.value, "Not found");
        users[msg.sender].amount_received = msg.value;
        users[msg.sender].payment_status = true;
        users[msg.sender].ticket_number = _ticket_number;
        _resultado = "Registered successfully";
    }
    function deposit2(uint256 _valor_esperado, uint256 _ticket_number) external payable returns(string memory _resultado){
        require(_valor_esperado == msg.value, "Not found");
        users[msg.sender].amount_received = msg.value;
        users[msg.sender].payment_status = true;
        users[msg.sender].ticket_number = _ticket_number;
        _resultado = "Registered successfully";
    }
    //pega o balanco do saldo atual do contrato em wei
    function balance() external view returns(uint256){
        return address(this).balance;
    }

    //retorna o valor, numero do boleto e estado da transacao
    function getUser(address _current_address)external view returns(uint256, uint256, bool){
        return (users[_current_address].amount_received, users[_current_address].ticket_number, users[_current_address].payment_status);
    }

    function revet_transaction(address _current_address) external returns(bool){
        Data_user storage _usuario = users[_current_address];
        require(_usuario.payment_status == true && msg.sender == owner, "unauthorized access");
        if (payable(_current_address).send((_usuario.amount_received))){
            delete users[_current_address];
            return true;
        }
        return (false);
    }
    function finalize_transaction(address _current_address) external returns(uint256, uint256, bool){
        require(msg.sender == owner, "unauthorized access");
        delete users[_current_address];
        return (users[_current_address].amount_received, users[_current_address].ticket_number, users[_current_address].payment_status);
    }
}