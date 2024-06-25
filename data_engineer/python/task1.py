from abc import ABC, abstractmethod

# класс, который будут соблюдать все процессоры платежей
class PaymentProcessor(ABC):
   @abstractmethod
   def pay(self, security_code):
      pass

class DebitPaymentProcessor(PaymentProcessor):
    def pay(self, security_code):
        print('Processing debit payment...')
        print(f'Verifying code: {security_code}')

class CreditPaymentProcessor(PaymentProcessor):
    def pay(self, security_code):
        print('Processing credit payment...')
        print(f'Verifying code: {security_code}')

class BankPaymentProcessor(PaymentProcessor):
    def pay(self, security_code):
        print('Processing bank payment...')
        print(f'Verifying code: {security_code}')

class Order:
    def __init__(self):
        self.items = []
        self.quantities = []
        self.prices = []
        self.status = 'open'

    def add_item(self, name, quantity, price):
        self.items.append(name)
        self.quantities.append(quantity)
        self.prices.append(price)

    def total_price(self):
        total = 0
        for i in range(len(self.prices)):
            total += self.quantities[i] * self.prices[i]
        return total

    def pay(self, payment_processor: PaymentProcessor, security_code):
        payment_processor.pay(security_code)
        self.status = 'paid'

def main() -> None:
    order = Order()
    order.add_item('Keyboard', 1, 50)
    order.add_item('SSD', 1, 150)
    order.add_item('USB cable', 2, 5)
    print(order.total_price())
    
    # Выбираем процессор платежей и совершаем оплату
    payment_processor = DebitPaymentProcessor()
    order.pay(payment_processor, '0372846')

if __name__ == "__main__":
    main()