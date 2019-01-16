pragma solidity ^0.4.24;

import "zos-lib/contracts/Initializable.sol";

contract AVLTree is Initializable {

    struct Node {
        uint id;
        uint key;
        uint8 height;
        uint leftId;
        uint rightId;
    }

    mapping (uint => Node) internal _nodes;
    uint internal _nodeId;

    Node internal _zeroNode;

    function initialize() public initializer {
        _nodeId = 1;
        _zeroNode = Node(0, 0, 0, 0, 0);
    }

    function _createNode(uint key) internal returns (Node storage) {
        uint id = _nodeId++;
        _nodes[id] = Node(id, key, 1, 0, 0);
        return _nodes[id];
    }

    function _getNode(uint id) internal view returns (Node storage) {
        return _nodes[id];
    }

    function _height(Node p) internal pure returns (uint8) {
        if (p.id != 0) {
            return p.height;
        }
        
        return 0;
    }

    function _bfactor(Node p) internal view returns (uint8) {
        return _height(_getNode(p.rightId)) - _height(_getNode(p.leftId));
    }

    function _fixheight(Node storage p) internal {
        uint8 hl = _height(_getNode(p.leftId));
        uint8 hr = _height(_getNode(p.rightId));
        p.height = ( hl > hr ? hl : hr ) + 1;
    }

    function _rotateright(Node storage p) internal returns (Node storage) {
        Node storage q = _getNode(p.leftId);
        p.leftId = q.rightId;
        q.rightId = p.id;
        _fixheight(p);
        _fixheight(q);
        return q;
    }

    function _rotateleft(Node storage q) internal returns (Node storage) {
        Node storage p = _getNode(q.rightId);
        q.rightId = p.leftId;
        p.leftId = q.id;
        _fixheight(q);
        _fixheight(p);
        return p;
    }

    function _balance(Node storage p) internal returns (Node storage) {
        _fixheight(p);
        if (_bfactor(p) == 2) {
            if (_bfactor(_getNode(p.rightId)) < 0) {
                p.rightId = _rotateright(_getNode(p.rightId)).id;
            }
            return _rotateleft(p);
        }

        if (_bfactor(p) == 254) { // -2 oveflown
            if (_bfactor(_getNode(p.leftId)) > 0) {
                p.leftId = _rotateleft(_getNode(p.leftId)).id;
            }

            return _rotateright(p);
        }

        return p;
    }

    function _insert(Node storage p, uint k) internal returns (Node storage) {
        if (p.id == 0) {
            return _createNode(k);
        }

        if (k < p.key) {
            p.leftId = _insert(_getNode(p.leftId), k).id;
        } else {
            p.rightId = _insert(_getNode(p.rightId), k).id;
        }

        return _balance(p);
    }

    function _findmin(Node storage p) internal view returns (Node storage) {
        return p.leftId != 0 ? _findmin(_getNode(p.leftId)) : p;
    }

    function _removemin(Node storage p) internal returns (Node storage) {
        if (p.leftId == 0) {
            return _getNode(p.rightId);
        }

        p.leftId = _removemin(_getNode(p.leftId)).id;
        return _balance(p);
    }

    function _remove(Node storage p, uint k) internal returns (Node storage) {
        if (p.id == 0) {
            return _zeroNode;
        }

        if (k < p.key) {
            p.leftId = _remove(_getNode(p.leftId), k).id;
        } else if (k > p.key) {
            p.rightId = _remove(_getNode(p.rightId), k).id;	
        } else {
            Node storage q = _getNode(p.leftId);
            Node storage r = _getNode(p.rightId);

            delete _nodes[p.id];

            if(r.id == 0) {
                return q;
            }

            Node storage min = _findmin(r);
            min.rightId = _removemin(r).id;
            min.leftId = q.id;

            return _balance(min);
        }

        return _balance(p);
    }

    // Public

    function insert(uint k) public {
        _insert(_zeroNode, k);
    }

    function getNodeById(uint idx) public view returns (uint id, uint key, uint8 height, uint leftId, uint rightId) {
        Node storage p = _getNode(idx);
        return (p.id, p.key, p.height, p.leftId, p.rightId);
    }

    function getLastId() public view returns (uint) {
        return _nodeId - 1;
    }
}