import torch
from transformers import *

def bert_download(path):
    ''' download both 'bert-base-multilingual-cased' model and tokenizer'''
    model = BertModel.from_pretrained("bert-base-multilingual-cased")
    tokenizer = BertTokenizer.from_pretrained("bert-base-multilingual-cased")
    model.save_pretrained(path)
    tokenizer.save_pretrained(path)
    return(path)

class MBERT():
    def __init__(self, path = None):
        self.model = BertModel.from_pretrained(path)
        self.tokenizer = BertTokenizer.from_pretrained(path)
    def embedding(self, content, max_length = 512, noise = True):
        """Assuming content to be a vector of text from R"""
        sentence_tensors = []
        if noise:
            print(content[0])
        for text in content:
            input_ids = self.tokenizer.encode(text, add_special_tokens = True, max_length = max_length, return_tensors = 'pt')
            with torch.no_grad():
                output_tuple = self.model(input_ids)
            output = output_tuple[0].squeeze()
            sentence_tensors.append(output)
        emb_torch = torch.cat(sentence_tensors, 0)
        if noise:
            print(emb_torch.size())
        doc_emb = emb_torch.mean(dim = 0)
        res = doc_emb.numpy()
        return(res)


# def bert_sentence(content, path, max_length = 512, noise = True):
#     """Assuming content to be a vector of text from R"""
#     model = BertModel.from_pretrained(path)
#     tokenizer = BertTokenizer.from_pretrained(path)
#     sentence_tensors = []
#     if noise:
#         print(content[0])
#     for text in content:
#         input_ids = tokenizer.encode(text, add_special_tokens = True, max_length = max_length, return_tensors = 'pt')		
#         with torch.no_grad():
#             output_tuple = model(input_ids)
#         output = output_tuple[0].squeeze()
#         sentence_tensors.append(output)
#     emb_torch = torch.cat(sentence_tensors, 0)
#     if noise:
#         print(emb_torch.size())
#     doc_emb = emb_torch.mean(dim = 0)
#     res = doc_emb.numpy()
#     return(res)

# def bert_corpus(corpus, model = BertModel.from_pretrained("bert-base-multilingual-cased"), tokenizer = BertTokenizer.from_pretrained("bert-base-multilingual-cased"), max_length = 512):
#     res = []
#     for content in corpus:
#         output = bert_sentence(content = content, model = model, tokenizer = tokenizer, max_length = max_length)
#         res.append(output)
#     return(res)

# def bert_tokenize(text, tokenizer = BertTokenizer.from_pretrained("bert-base-multilingual-cased")):
#     return tokenizer.encode(text, add_special_tokens = False)

